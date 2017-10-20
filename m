From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vmxnet3: Use correct minimum MTU value
Date: Fri, 20 Oct 2017 07:15:48 +0100 (WEST)
Message-ID: <20171020.071548.524144466372098011.davem@davemloft.net>
References: <1508250823-1954-1-git-send-email-mgamal@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, skhare@vmware.com, pv-drivers@vmware.com,
        linux-kernel@vger.kernel.org, cavery@redhat.com, otubo@redhat.com,
        vkuznets@redhat.com
To: mgamal@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1508250823-1954-1-git-send-email-mgamal@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mohammed Gamal <mgamal@redhat.com>
Date: Tue, 17 Oct 2017 16:33:43 +0200

> Currently the vmxnet3 driver has a minimum MTU value of 60. Which
> goes against the RFC791 spec which specifies it at 68.
> 
> Setting MTU to values between 60 <= MTU <= 67 causes the network
> interface to lose its IP, and it fails to restart.
> 
> This sets the minimum value to ETH_MIN_MTU (68) which is compatible
> with is according to spec.
> 
> Reported-by: Bo Yang <boyang@redhat.com>
> Signed-off-by: Mohammed Gamal <mgamal@redhat.com>

There are protocols other than IPv4, and as Andrew mentioned
the ipv4 stack does the right thing by disabling ipv4 on
an interface when the MTU is too small.
