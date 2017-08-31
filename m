From: Mike Galbraith <efault@gmx.de>
Subject: Re: tip -ENOBOOT - bisected to locking/refcounts, x86/asm:
 Implement fast refcount overflow protection
Date: Thu, 31 Aug 2017 19:19:27 +0200
Message-ID: <1504199967.666.16.camel@gmx.de>
References: <1503996623.8323.20.camel@gmx.de>
         <CAGXu5jLYHy6Damtg_Pc4=G76OUiMV3fcY9+Ru1-Lmiq6VWEgsw@mail.gmail.com>
         <1504025721.6024.25.camel@gmx.de> <1504030207.6560.0.camel@gmx.de>
         <CAGXu5jKSWiZ8NkgUqO6G8fs5R06bMtdFBmZz9MMX-HAk8nXXNw@mail.gmail.com>
         <1504069332.8352.3.camel@gmx.de>
         <CAGXu5jJim=r8b+y1qQXtuzm9fPyv1tp9ANebxbCc9ic2c83_Mg@mail.gmail.com>
         <1504113212.5852.6.camel@gmx.de>
         <CAGXu5jJd80-0PJvB51x9ZDETPSoAtRVQ7dQ6HWwd0DYpKBgPFA@mail.gmail.com>
         <1504115735.5852.11.camel@gmx.de>
         <CAGXu5j+BLj6_LPfKs-vts-mbyJHu8D--WrmWbiT8Zbt-iD65KA@mail.gmail.com>
         <CAGXu5j+neSYAqb8=r42=jQ0LsJTGjCSdpgc9Hv+ipyAFURbCdw@mail.gmail.com>
         <1504145389.23109.4.camel@gmx.de>
         <CAGXu5jLKXEDdSpxxVM5oHHUWKbSTozx4FZRn70bQm4tQAhMqUQ@mail.gmail.com>
         <1504149176.23109.9.camel@gmx.de>
         <CAGXu5j+uNU+wqWoCV+Kpdp+DQer4E3VuwO0mtXiW3Dtw_61QKA@mail.gmail.com>
         <CAGXu5jKYPp5D+YxtqrJXsi48UUbjfeREngsys-dU1eP4RnnL+w@mail.gmail.com>
         <1504187918.27500.16.camel@gmx.de>
         <CAGXu5jL8Ueuw-DLY+Hz8Jd7NgqgyaaN8OVDicFxmcjBhScebOA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: "David S. Miller" <davem@davemloft.net>,
        Peter Zijlstra <peterz@infradead.org>,
        LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>,
        "Reshetova, Elena" <elena.reshetova@intel.com>,
        Network Development <netdev@vger.kernel.org>
To: Kees Cook <keescook@chromium.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAGXu5jL8Ueuw-DLY+Hz8Jd7NgqgyaaN8OVDicFxmcjBhScebOA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2017-08-31 at 10:00 -0700, Kees Cook wrote:
> 
> Oh! So it's gcc-version sensitive? That's alarming. Is this mapping correct:
> 
> 4.8.5: WARN, eventual kernel hang
> 6.3.1, 7.0.1: WARN, but continues working

Yeah, that's correct.  I find that troubling, simply because this gcc
version has been through one hell of a lot of kernels with me.  Yeah, I
know, that doesn't exempt it from having bugs, but color me suspicious.

	-Mike
