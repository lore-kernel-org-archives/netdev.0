From: Shreyas Bhatewara <sbhatewara@vmware.com>
Subject: Re: [PATCH] vmxnet3: must split too big fragments
Date: Mon, 29 Oct 2012 11:17:19 -0700 (PDT)
Message-ID: <428233753.11168915.1351534639870.JavaMail.root@vmware.com>
References: <1351531849.12280.54.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "VMware, Inc." <pv-drivers@vmware.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	jongman heo <jongman.heo@samsung.com>,
	David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1351531849.12280.54.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



----- Original Message -----
> From: Eric Dumazet <edumazet@google.com>
> 
> vmxnet3 has a 16Kbytes limit per tx descriptor, that happened to work
> as long as we provided PAGE_SIZE fragments.
> 
> Our stack can now build larger fragments, so we need to split them to
> the 16kbytes boundary.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: jongman heo <jongman.heo@samsung.com>
> Tested-by: jongman heo <jongman.heo@samsung.com>
> Cc: Shreyas Bhatewara <sbhatewara@vmware.com>
> ---
>  drivers/net/vmxnet3/vmxnet3_drv.c |   65
>  +++++++++++++++++++---------
>  1 file changed, 45 insertions(+), 20 deletions(-)
> 

Thanks for the patch Eric.

Signed-of-by: Shreyas Bhatewara <sbhatewara@vmware.com>
