From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] xen-netfront: Delete rx_refill_timer in
 xennet_disconnect_backend()
Date: Wed, 01 Feb 2017 16:01:17 -0800
Message-ID: <1485993677.6360.173.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1485798346-4425-1-git-send-email-boris.ostrovsky@oracle.com>
         <1485799651.6360.101.camel@edumazet-glaptop3.roam.corp.google.com>
         <40057d9d-c615-1a2b-63a2-ab717c29d659@oracle.com>
         <1485803209.6360.111.camel@edumazet-glaptop3.roam.corp.google.com>
         <07a315d6-7c97-6d11-fa18-548000107c2f@oracle.com>
         <10b1d554-b395-88fa-eee3-a77754ad14bd@oracle.com>
         <223ebf32-ba8b-a6be-2331-0644f9d347a0@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: jgross@suse.com, xen-devel@lists.xenproject.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        vineethp@amazon.com, wei.liu2@citrix.com, paul.durrant@citrix.com,
        stable@vger.kernel.org, Ross Lagerwall <ross.lagerwall@citrix.com>
To: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <223ebf32-ba8b-a6be-2331-0644f9d347a0@oracle.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2017-02-01 at 18:29 -0500, Boris Ostrovsky wrote:

> 
> I could not convince myself that napi_synchronize() is sufficient here
> (mostly because I am not familiar with napi flow). At the same time I
> would rather not make changes in anticipation of possible disappearance
> of netif_carrier_ok() in the future so I'd like this patch to go in as is.
> 
> Unless there are other problems with the patch or if Eric (or others)
> feel strongly about usage of netif_carrier_ok() here.
> 

No strong feelings from me.
We probably have more serious issues to fix anyway.
