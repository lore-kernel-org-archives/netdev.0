From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Subject: Re: [PATCH] 2.6.14-rc4: wider use of for_each_*cpu() in net
Date: Fri, 28 Oct 2005 14:02:50 -0200
Message-ID: <39e6f6c70510280902q30b43634nc68324a371d7d910@mail.gmail.com>
References: <20051013190133.13192.46039.sendpatchset@tomahawk.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1030234AbVJ1QCw@vger.kernel.org>
To: "hawkes@sgi.com" <hawkes@sgi.com>
In-Reply-To: <20051013190133.13192.46039.sendpatchset@tomahawk.engr.sgi.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/13/05, hawkes@sgi.com <hawkes@sgi.com> wrote:
> In 'net' change the explicit use of for-loops and NR_CPUS into the
> general for_each_cpu() or for_each_online_cpu() constructs, as
> appropriate.  This widens the scope of potential future optimizations
> of the general constructs, as well as takes advantage of the existing
> optimizations of first_cpu() and next_cpu(), which is advantageous
> when the true CPU count is much smaller than NR_CPUS.
>
> Signed-off-by: John Hawkes <hawkes@sgi.com>

Thanks, applied and pushed to Linus,

- Arnaldo
