From: "Tom Lendacky" <toml@us.ibm.com>
Subject: Re: Flow cache flush oops
Date: Wed, 18 Jun 2003 18:10:48 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OFF5CE2037.3D4C9104-ON86256D49.007EAEAD-86256D49.007F5519@pok.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@redhat.com, kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


   If your compiler is producing anything like mine, then edi should be
   smp_processor_id() which looks a bit weird.  Please send me your
   net/core/flow.o file so that I can compare it.

   What compiler are you using? And how many CPUs?

The compiler version output is:
  gcc version 3.2 20020903 (Red Hat Linux 8.0 3.2-7)

The system has 4 CPUs.

Herbert, I'll send the flow.o file to you separately.

Thanks,
Tom
