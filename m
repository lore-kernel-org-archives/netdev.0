From: Michael Chan <michael.chan@broadcom.com>
Subject: Re: [PATCH v2 net-next] bnxt: add dma mapping attributes
Date: Tue, 9 May 2017 19:16:37 -0700
Message-ID: <CACKFLimzVSgb92EmiZ44Xr7G=Xi8FD+wrs7dgY6jg8vdVMBOSA@mail.gmail.com>
References: <1494379812-282087-1-git-send-email-shannon.nelson@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        Netdev <netdev@vger.kernel.org>, sparclinux@vger.kernel.org
To: Shannon Nelson <shannon.nelson@oracle.com>
Return-path: <sparclinux-owner@vger.kernel.org>
In-Reply-To: <1494379812-282087-1-git-send-email-shannon.nelson@oracle.com>
Sender: sparclinux-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 9, 2017 at 6:30 PM, Shannon Nelson
<shannon.nelson@oracle.com> wrote:
> On the SPARC platform we need to use the DMA_ATTR_WEAK_ORDERING attribute
> in our Rx path dma mapping in order to get the expected performance out
> of the receive path.  Adding it to the Tx path has little effect, so
> that's not a part of this patch.
>
> Signed-off-by: Shannon Nelson <shannon.nelson@oracle.com>
> Reviewed-by: Tushar Dave <tushar.n.dave@oracle.com>
> Reviewed-by: Tom Saeger <tom.saeger@oracle.com>
> ---
> v2: simplify by getting rid of the driver-specific ifdef and define

Acked-by: Michael Chan <michael.chan@broadcom.com>
