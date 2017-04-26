From: Randy Dunlap <rdunlap@infradead.org>
Subject: Re: linux-next: Tree for Apr 26 (net/can/bcm.c)
Date: Wed, 26 Apr 2017 07:53:24 -0700
Message-ID: <05bd24d8-6840-3551-a529-c464f3b26d0a@infradead.org>
References: <20170426180321.3c8c16a2@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        linux-can@vger.kernel.org
To: Stephen Rothwell <sfr@canb.auug.org.au>,
        Linux-Next Mailing List <linux-next@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170426180321.3c8c16a2@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/26/17 01:03, Stephen Rothwell wrote:
> Hi all,
> 
> Changes since 20170424:
> 

on x86_64:

when CONFIG_PROC_FS is not enabled:

../net/can/bcm.c:1541:14: error: 'struct netns_can' has no member named 'bcmproc_dir'
../net/can/bcm.c:1601:14: error: 'struct netns_can' has no member named 'bcmproc_dir'
../net/can/bcm.c:1696:11: error: 'struct netns_can' has no member named 'bcmproc_dir'
../net/can/bcm.c:1707:15: error: 'struct netns_can' has no member named 'bcmproc_dir'

2 of those are "protected" by
	if (IS_ENABLED(CONFIG_PROC_FS)) {
but that doesn't seem to help/work here.

gcc v4.8.5



-- 
~Randy
