From: "Justin P. Mattock" <justinmattock@gmail.com>
Subject: Re: BUG: unable to handle kernel NULL pointer dereference at 00000000000000a0
Date: Wed, 23 Jun 2010 07:41:07 -0700
Message-ID: <4C221D03.9050006@gmail.com>
References: <AANLkTilf41JrFwN1veRDifNA78S2LQ6SO0g3YLOONd2W@mail.gmail.com> <20100623141622.GC15205@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100623141622.GC15205@tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/23/2010 07:16 AM, John W. Linville wrote:
> On Tue, Jun 22, 2010 at 04:16:53PM -0700, Justin Mattock wrote:
>> I remember ipsec was able to work cleanly on my machines probably
>> about 4/6 months ago
>> now I get this:
>
> <snip>
>
> Perhaps netdev would be a more appropriate list than linux-wireless
> for this?
>
> John

alright added the cc's..
almost done bisecting..hopefully this points to
the right area..(if not I'll re-bisect until I get this).

as for the troubled machines I've a macbookpro2,2(no proprietary
stuff) and an imac9,1 with broadcom-sta(blah) both
seem to hit this right when the ipsec transaction starts
with ssh, vncviewer..(last good kernel I have is
2.6.33-rc5-01007-ge9449d8).

Justin P. Mattock
