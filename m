From: Juergen Gross <jgross@suse.com>
Subject: Re: [PATCH] xen-netfront: Delete rx_refill_timer in
 xennet_disconnect_backend()
Date: Fri, 3 Feb 2017 10:38:14 +0100
Message-ID: <bc3bf927-568e-043a-2785-16e6c3628359@suse.com>
References: <1485798346-4425-1-git-send-email-boris.ostrovsky@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: xen-devel@lists.xenproject.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, vineethp@amazon.com,
        wei.liu2@citrix.com, paul.durrant@citrix.com,
        stable@vger.kernel.org
To: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1485798346-4425-1-git-send-email-boris.ostrovsky@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 30/01/17 18:45, Boris Ostrovsky wrote:
> rx_refill_timer should be deleted as soon as we disconnect from the
> backend since otherwise it is possible for the timer to go off before
> we get to xennet_destroy_queues(). If this happens we may dereference
> queue->rx.sring which is set to NULL in xennet_disconnect_backend().
> 
> Signed-off-by: Boris Ostrovsky <boris.ostrovsky@oracle.com>
> CC: stable@vger.kernel.org

Reviewed-by: Juergen Gross <jgross@suse.com>


Juergen
