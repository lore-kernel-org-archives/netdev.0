From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH v2] arm: eBPF JIT compiler
Date: Wed, 21 Jun 2017 18:32:37 +0200
Message-ID: <594A9FA5.1080003@iogearbox.net>
References: <1495754003-21099-1-git-send-email-illusionist.neo@gmail.com> <CAGXu5jKmLNMR+uhM9Ov2XPW6kCjip_SjScgEH0fTFp6fQtKFiA@mail.gmail.com> <593E6B0F.8070901@iogearbox.net> <CAHgaXd+DW2bggto=2S9hOdMrtPTvhD2QN4rPf2V8iHewQpg-YA@mail.gmail.com> <CAHgaXdJrvKdzr3fJ1TMkC4foeVsZJDSVEwhDOeZGxQVsmoK2cQ@mail.gmail.com> <59419D1E.2060303@iogearbox.net> <CAHgaXdKMbFPgy-kKF0iDSAYo4CqLn9FRu9HwM+OfM-JWb9fNRQ@mail.gmail.com> <594813AA.5010001@iogearbox.net> <CAHgaXdLtX6yLdU3bMvS=g8FZ79sM_BW_+hHTMH=Mfk4TZqUnpw@mail.gmail.com> <59495367.3080402@iogearbox.net> <CAHgaXdKGJFh8jO44gwCqe0cijoztf39bK9k8ioBtYDjzb4vvZw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Kees Cook <keescook@chromium.org>,
        Network Development <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Alexei Starovoitov <ast@kernel.org>,
        Russell King <linux@armlinux.org.uk>,
        "linux-arm-kernel@lists.infradead.org"
        <linux-arm-kernel@lists.infradead.org>,
        LKML <linux-kernel@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Shubham Bansal <illusionist.neo@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAHgaXdKGJFh8jO44gwCqe0cijoztf39bK9k8ioBtYDjzb4vvZw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/21/2017 04:26 PM, Shubham Bansal wrote:
[...]
> So ultimately, we call helper_function which takes u64 as arguments
> only. I know its asking a lot, but can you please confirm this asap? I
> would like to start implementing it.

Yes, that is correct. I think it would be the better, more generic
approach going forward to always assume that.
