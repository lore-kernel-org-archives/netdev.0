From: Sedat Dilek <sedat.dilek@gmail.com>
Subject: Re: net.git: Call-trace after "Merge branch 'netlink_multicast'"
Date: Sun, 28 Dec 2014 08:54:53 +0100
Message-ID: <CA+icZUU1-o7m9iYNpHyitpbS8W=+mk-ZbBXiK2Zgow2TDnBo1Q@mail.gmail.com>
References: <CA+icZUVkNHBqCn66onJP9i5vfVzHR9mdSFXyiBFyjhkrySrSzQ@mail.gmail.com>
	<CA+icZUWFq0FT5QQThKeeVw4=-41R7W0Q7zv53ZCY9=B6AJvf7w@mail.gmail.com>
Reply-To: sedat.dilek@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Fengguang Wu <fengguang.wu@intel.com>
To: Johannes Berg <johannes.berg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f182.google.com ([209.85.212.182]:57105 "EHLO
	mail-wi0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751170AbaL1Hyz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Dec 2014 02:54:55 -0500
Received: by mail-wi0-f182.google.com with SMTP id h11so19718737wiw.3
        for <netdev@vger.kernel.org>; Sat, 27 Dec 2014 23:54:53 -0800 (PST)
In-Reply-To: <CA+icZUWFq0FT5QQThKeeVw4=-41R7W0Q7zv53ZCY9=B6AJvf7w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Just a small thing, if you look at this...

With gcc-4.9.2 I see this warning in my logs...

net/netlink/genetlink.c: In function 'genl_bind':
net/netlink/genetlink.c:1018:2: warning: 'err' may be used
uninitialized in this function [-Wmaybe-uninitialized]

- Sedat -

P.S.: Some gcc-4.9 outputs

$ cat /proc/version
Linux version 3.19.0-rc1-58.2-iniza-small
(sedat.dilek@gmail.com@fambox) (gcc version 4.9.2 (Ubuntu
4.9.2-0ubuntu1~12.04) ) #1 SMP Sun Dec 28 08:09:51 CET 2014

$ gcc-4.9 -v
Using built-in specs.
COLLECT_GCC=gcc-4.9
COLLECT_LTO_WRAPPER=/usr/lib/gcc/x86_64-linux-gnu/4.9/lto-wrapper
Target: x86_64-linux-gnu
Configured with: ../src/configure -v --with-pkgversion='Ubuntu
4.9.2-0ubuntu1~12.04'
--with-bugurl=file:///usr/share/doc/gcc-4.9/README.Bugs
--enable-languages=c,c++,java,go,d,fortran,objc,obj-c++ --prefix=/usr
--program-suffix=-4.9 --enable-shared --enable-linker-build-id
--libexecdir=/usr/lib --without-included-gettext
--enable-threads=posix --with-gxx-include-dir=/usr/include/c++/4.9
--libdir=/usr/lib --enable-nls --with-sysroot=/ --enable-clocale=gnu
--enable-libstdcxx-debug --enable-libstdcxx-time=yes
--enable-gnu-unique-object --disable-vtable-verify --enable-plugin
--with-system-zlib --disable-browser-plugin --enable-java-awt=gtk
--enable-gtk-cairo
--with-java-home=/usr/lib/jvm/java-1.5.0-gcj-4.9-amd64/jre
--enable-java-home
--with-jvm-root-dir=/usr/lib/jvm/java-1.5.0-gcj-4.9-amd64
--with-jvm-jar-dir=/usr/lib/jvm-exports/java-1.5.0-gcj-4.9-amd64
--with-arch-directory=amd64
--with-ecj-jar=/usr/share/java/eclipse-ecj.jar --enable-objc-gc
--enable-multiarch --disable-werror --with-arch-32=i686 --with-abi=m64
--with-multilib-list=m32,m64 --enable-multilib --with-tune=generic
--enable-checking=release --build=x86_64-linux-gnu
--host=x86_64-linux-gnu --target=x86_64-linux-gnu
Thread model: posix
gcc version 4.9.2 (Ubuntu 4.9.2-0ubuntu1~12.04)
