From: maximilian attems <max@stro.at>
Subject: Re: bnx2 dirver's firmware images
Date: Wed, 19 Sep 2007 19:18:41 +0200
Message-ID: <20070919171841.GT19918@baikonur.stro.at>
References: <46F01BDE.6020902@zytor.com> <20070918.122034.83625273.davem@davemloft.net> <46F02688.8030507@zytor.com> <20070918.130810.78161599.davem@davemloft.net> <20070918203530.GC27836@uranus.ravnborg.org> <20070919171033.GH6618@stro.at> <46F15886.6040701@zytor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sam Ravnborg <sam@ravnborg.org>,
	David Miller <davem@davemloft.net>, mchan@broadcom.com,
	vda.linux@googlemail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: "H. Peter Anvin" <hpa@zytor.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756356AbXISRS7@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <46F15886.6040701@zytor.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 19, 2007 at 10:12:38AM -0700, H. Peter Anvin wrote:
> 
> Could you give a concrete example?
> 
> 	-hpa

max@dual:~/src/klibc$ touch usr/utils/mount_main.c
max@dual:~/src/klibc$ make
  KLIBCCC usr/utils/mount_main.o
  KLIBCLD usr/utils/static/halt
  LN      usr/utils/static/reboot
  LN      usr/utils/static/poweroff
  KLIBCLD usr/utils/shared/halt
  LN      usr/utils/shared/reboot
  LN      usr/utils/shared/poweroff
  KLIBCLD usr/utils/static/chroot
  KLIBCLD usr/utils/static/dd
  <snipp>

-- 
maks
