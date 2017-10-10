From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH v2] xdp: Sample xdp program implementing ip forward
Date: Tue, 10 Oct 2017 10:21:22 -0700
Message-ID: <20171010102122.6ca1e756@shemminger-XPS-13-9360>
References: <1507620532-25804-1-git-send-email-Christina.Jacob@cavium.com>
        <1507620532-25804-2-git-send-email-Christina.Jacob@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org, brouer@redhat.com,
        Sunil.Goutham@cavium.com, daniel@iogearbox.net, dsahern@gmail.com,
        Christina Jacob <Christina.Jacob@cavium.com>
To: Christina Jacob <christina.jacob.koikara@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1507620532-25804-2-git-send-email-Christina.Jacob@cavium.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 10 Oct 2017 12:58:52 +0530
Christina Jacob <christina.jacob.koikara@gmail.com> wrote:

> +		bzero(&route, sizeof(route));
> +		bzero(dsts, sizeof(dsts));
> +		bzero(dsts_len, sizeof(dsts_len));
> +		bzero(gws, sizeof(gws));
> +		bzero(ifs, sizeof(ifs));
> +		bzero(&route, sizeof(route));

This is all unnecessary.
It looks like you write OpenBSD security code.
Only a security person would zero stack variables before return
and only BSD people use bzero(), Linux style is to use memset.
