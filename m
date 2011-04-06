From: Michal Marek <mmarek@suse.cz>
Subject: Re: [PATCH 12/34] isdn/diva: Drop __TIME__ usage
Date: Wed, 06 Apr 2011 10:06:52 +0200
Message-ID: <4D9C1F1C.50802@suse.cz>
References: <1302015561-21047-1-git-send-email-mmarek@suse.cz> <1302015561-21047-13-git-send-email-mmarek@suse.cz>            <alpine.DEB.2.00.1104051709040.7262@justus.melware.de> <20627.1302031056@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Armin Schindler <armin@melware.de>, linux-kbuild@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Valdis.Kletnieks@vt.edu
Return-path: <linux-kbuild-owner@vger.kernel.org>
In-Reply-To: <20627.1302031056@localhost>
Sender: linux-kbuild-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 5.4.2011 21:17, Valdis.Kletnieks@vt.edu wrote:
> On Tue, 05 Apr 2011 17:10:34 +0200, Armin Schindler said:
>> On Tue, 5 Apr 2011, Michal Marek wrote:
>>> The kernel already prints its build timestamp during boot, no need to
>>> repeat it in random drivers and produce different object files each
>>> time.
>>
>> The module can be build separately from the kernel, therefore it can have
>> an own build timestamp.
> 
> If the same code is being built as an out-of-tree module, that's a possibly
> good reason for a code version variable, but what does the build timestamp
> actually tell you?  If you already know foo_driver.c version 0.814 was buiilt
> against 2.6.41-rc2, in what cases does it matter if the compile was on Tuesday
> or Thursday - especially since an 'ls -l foo_driver.ko' will tell you?  If it's
> a matter of "the target .config changed on Wednesday", a build timestamp still
> doesn't help over 'ls -l'.

Exactly. Build timestamps are only a poor substitute for proper version
tracking. If you want to be able to reproduce the build of a binary, you
want it to embed some source revision, not the date when you built it.
For the kernel, you can use KBUILD_BUILD_TIMESTAMP=<source timestamp>,
for out-of-tree modules, you need to come up with something own.

Michal
