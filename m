From: "H. Peter Anvin" <hpa@zytor.com>
Subject: Re: [PATCH] x86: Wire up 32-bit direct socket calls
Date: Wed, 02 Sep 2015 13:16:19 -0700
Message-ID: <55E75913.5050605@zytor.com>
References: <cb5138299d37d5800e2d135b01a7667fa6115854.1436912629.git.luto@kernel.org> <CAMuHMdXKA_+JY2ryf-yoJxQnbW=jsOjj_w2-Nsybpx0310neDA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: X86 ML <x86@kernel.org>, Network Development <netdev@vger.kernel.org>,
        Tulio Magno Quites Machado Filho <tuliom@linux.vnet.ibm.com>,
        Andy Lutomirski <luto@amacapital.net>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Alexander Larsson <alexl@redhat.com>,
        Cosimo Cecchi <cosimo@endlessm.com>,
        Dan Nicholson <nicholson@endlessm.com>,
        libc-alpha <libc-alpha@sourceware.org>,
        Rajalakshmi Srinivasaraghavan <raji@linux.vnet.ibm.com>,
        Linux-Arch <linux-arch@vger.kernel.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>,
        Andy Lutomirski <luto@kernel.org>
Return-path: <libc-alpha-return-62908-glibc-alpha=m.gmane.org@sourceware.org>
List-Unsubscribe: <mailto:libc-alpha-unsubscribe-glibc-alpha=m.gmane.org@sourceware.org>
List-Subscribe: <mailto:libc-alpha-subscribe@sourceware.org>
List-Archive: <http://sourceware.org/ml/libc-alpha/>
List-Post: <mailto:libc-alpha@sourceware.org>
List-Help: <mailto:libc-alpha-help@sourceware.org>, <http://sourceware.org/ml/#faqs>
Sender: libc-alpha-owner@sourceware.org
In-Reply-To: <CAMuHMdXKA_+JY2ryf-yoJxQnbW=jsOjj_w2-Nsybpx0310neDA@mail.gmail.com>
List-Id: netdev.vger.kernel.org

On 09/02/2015 02:48 AM, Geert Uytterhoeven wrote:
> 
> Should all other architectures follow suit?
> Or should we follow the s390 approach:
> 

It is up to the maintainer(s), largely dependent on how likely you are
going to want to support this in your libc, but in general, socketcall
is an abomination which there is no reason not to bypass.

So follow suit unless you have a strong reason not to.

	-hpa
