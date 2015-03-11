From: Olaf Hering <olaf@aepfle.de>
Subject: Re: [PATCH 2/2 net-next] hyperv: Support batched notification
Date: Wed, 11 Mar 2015 10:23:54 +0100
Message-ID: <20150311092354.GA13144@aepfle.de>
References: <1426013383-2853-1-git-send-email-kys@microsoft.com>
 <1426013404-2892-1-git-send-email-kys@microsoft.com>
 <1426013404-2892-2-git-send-email-kys@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org,
	devel@linuxdriverproject.org, apw@canonical.com,
	jasowang@redhat.com
To: "K. Y. Srinivasan" <kys@microsoft.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1426013404-2892-2-git-send-email-kys@microsoft.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 10, K. Y. Srinivasan wrote:

> Optimize notifying the host by deferring notification until there
> are no more packets to be sent. This will help in batching the requests
> on the host.

The subjects for the network driver say "hyperv:". But all such changes
should get "netvsc:" as prefix to make it clear what each single patch
is all about.

This should be changed for upcoming submissions.

Thanks!

Olaf
