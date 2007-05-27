From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Link always down
Date: Mon, 28 May 2007 00:20:24 +0200
Message-ID: <20070527222024.GA15066@electric-eye.fr.zoreil.com>
References: <46557430.5060501@tugraz.at> <20070524120644.GA7224@electric-eye.fr.zoreil.com> <46569CF4.2030108@tugraz.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Clemens Brunner <clemens.brunner@tugraz.at>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:33419 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753326AbXE0WXv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 27 May 2007 18:23:51 -0400
Content-Disposition: inline
In-Reply-To: <46569CF4.2030108@tugraz.at>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Clemens Brunner <clemens.brunner@tugraz.at> :
[...]
> I've compiled and installed the latest kernel 2.6.22-rc2, but I wasn't able 
> to apply your patch (using bzip2 -dc /usr/src/r8169-20070522.tar.bz2 | 
> patch p1 --dry-run yielded the message "Reversed (or previously applied) 
> patch detected!", so I guess this patch was already included in the latest 
> kernel source).

The patch is not included in the latest kernel source.

Actually, you are not supposed to use the patch-kit this way. If you do
a 'tar jxvf r8169-20070522.tar.bz2', you should notice that the archive
file is extracted into a nice directory which contains a serie of patches.
You should follow the numbering of the patches and apply them to a clean
2.6.22-rc2 tree (i.e. apply 0001-foo, 0002-bar, 0003-frob, usw).

As an option you can retrieve the url below which contains all the patches
above in a single patch-file:
http://www.fr.zoreil.com/people/francois/misc/20070522-2.6.22-rc2-r8169.patch

The patch-kit allows to peel the onion more easily when somthing goes
wrong.

Btw, I have just updated everything for 2.6.22-rc3, you should try any of
http://www.fr.zoreil.com/linux/kernel/2.6.x/2.6.22-rc3
http://www.fr.zoreil.com/people/francois/misc/20070527-2.6.22-rc3-r8169.patch

If you use 'make oldconfig' to update your config, you will be prompted
for 'EEPROM 93CX6 support' as the relevant bits have been extracted from
the wireless-dev git tree to access the EEPROM connected to the 816x.
Don't disable it.

-- 
Ueimor
