From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH v2 05/11] Kbuild: don't add obj tree in additional includes
Date: Tue, 19 Jul 2016 17:33:44 +0300
Message-ID: <87a8hdae9j.fsf@purkki.adurom.net>
References: <20160615154553.3177021-1-arnd@arndb.de>
	<20160615154553.3177021-6-arnd@arndb.de>
	<20160718201439.GA9053@sepie.suse.cz> <21521763.EfAflxWUP8@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-arm-kernel@lists.infradead.org,
	Michal Marek <mmarek@suse.com>, netdev@vger.kernel.org,
	dri-devel@lists.freedesktop.org, linux-kernel@vger.kernel.org,
	linux-kbuild@vger.kernel.org, akpm <akpm@linux-foundation.org>,
	linux-wireless@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kbuild-owner@vger.kernel.org>
In-Reply-To: <21521763.EfAflxWUP8@wuerfel> (Arnd Bergmann's message of "Tue,
	19 Jul 2016 10:31:26 +0200")
Sender: linux-kbuild-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arnd Bergmann <arnd@arndb.de> writes:

> On Monday, July 18, 2016 10:14:39 PM CEST Michal Marek wrote:
>> On Wed, Jun 15, 2016 at 05:45:47PM +0200, Arnd Bergmann wrote:
>> > When building with separate object directories and driver specific
>> > Makefiles that add additional header include paths, Kbuild adjusts
>> > the gcc flags so that we include both the directory in the source
>> > tree and in the object tree.
>> > 
>> > However, due to another bug I fixed earlier, this did not actually
>> > include the correct directory in the object tree, so we know that
>> > we only really need the source tree here. Also, including the
>> > object tree sometimes causes warnings about nonexisting directories
>> > when the include path only exists in the source.
>> > 
>> > This changes the logic to only emit the -I argument for the srctree,
>> > not for objects. We still need both $(srctree)/$(src) and $(obj)
>> > though, so I'm adding them manually.
>> > 
>> > Signed-off-by: Arnd Bergmann <arnd@arndb.de>
>> 
>> Hi Arnd,
>> 
>> I applied the series up to this patch to kbuild.git#kbuild. The rest
>> seem to be related but not dependent patches, so I'll leave it up to the
>> respective maintainers to pick them up. Is that OK with you?
>
> I think that's fine, a couple were already picked up, and what I have
> left now is
>
> a281bfa5713a [SUBMITTED 20160615] [EXPERIMENTAL] Kbuild: enable -Wmissing-include-dirs by default
> 83934921e68e [SUBMITTED 20160615] rtlwifi: don't add include path for rtl8188ee

Apparently[1] you didn't CC linux-wireless and that's why I didn't see
the rtlwifi patch in wireless patchwork. Care to resend?

[1] https://patchwork.kernel.org/patch/9178861/

-- 
Kalle Valo
