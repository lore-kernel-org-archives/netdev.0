From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: where is the proper place for r8169 bug reports?
Date: Wed, 2 Feb 2005 23:13:33 +0100
Message-ID: <20050202221333.GA24020@electric-eye.fr.zoreil.com>
References: <20050131181508.GA15908@gerbil.toadis.porkis> <20050131214951.GA13217@electric-eye.fr.zoreil.com> <20050131215948.GA23289@gerbil.toadis.porkis> <20050131222342.GB13217@electric-eye.fr.zoreil.com> <20050201215607.GA8530@gerbil.toadis.porkis> <20050201223109.GA2957@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
To: "Dale E. Martin" <dale@the-martins.org>
Content-Disposition: inline
In-Reply-To: <20050201223109.GA2957@electric-eye.fr.zoreil.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Re,

- the 2.4.x backport has been rediffed against 2.4.29 (mostly harmless
  conflict in drivers/net/Config.in);
- the driver compiles again when RTL8169_DEBUG is defined;
- endianness fix in the Rx checksumming path.

A test report with your 2.95.3 compiler would be welcome. If it breaks,
the r8169.o file and an estimate of the transmitted/received packets count
will help. If none is available, the number of interrupts processed can
help too.

Patch against 2.4.29 (md5: 444748e3c6c56382cb02adea4d16b5cf)
http://www.fr.zoreil.com/~romieu/misc/20050202-2.4.29-r8169.c-test.patch

Same thing a la patch-script:
http://www.fr.zoreil.com/linux/kernel/2.4.x/2.4.29/r8169/

Patch-script in a single file:
http://www.fr.zoreil.com/linux/kernel/2.4.x/2.4.29/r8169-blob.tar.bz2

--
Ueimor
