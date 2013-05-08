From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: Linux driver for Realtek RTL8723AU devices with USB ID 0bda:1724
 such as found in Lenovo IdeaPad Yoga 13
Date: Wed, 8 May 2013 17:43:52 +0100
Message-ID: <20130508164351.GU25399@ZenIV.linux.org.uk>
References: <5159B52D.3050601@lwfinger.net>
 <5189B939.4010905@zytor.com>
 <518A7814.1070604@lwfinger.net>
 <518A7D56.3050502@zytor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Larry Finger <Larry.Finger@lwfinger.net>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>, Dan Williams <dcbw@redhat.com>,
	'George0505' <george0505@realtek.com>,
	Joon Ro <joonhyoung.ro@gmail.com>,
	Greg KH <gregkh@linux-foundation.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <518A7D56.3050502@zytor.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 08, 2013 at 09:29:10AM -0700, H. Peter Anvin wrote:
> Unlikely, since the kernel source tree is clean.
> 
> The error is on os_dep/os_intfs.c:
> 
> /home/hpa/kernel/rtl8723au/os_dep/os_intfs.c: In function
> ?rtw_proc_init_one?:
> /home/hpa/kernel/rtl8723au/os_dep/os_intfs.c:315:3: error: implicit
> declaration of function ?create_proc_entry?

create_proc_entry is gone (and good riddance); use proc_create()

> /home/hpa/kernel/rtl8723au/os_dep/os_intfs.c:322:3: error: implicit
> declaration of function ?create_proc_read_entry?

ditto.

> /home/hpa/kernel/rtl8723au/os_dep/os_intfs.c:370:7: error:
> dereferencing pointer to incomplete type

... and don't poke in proc_dir_entry innards, while we are at it.
