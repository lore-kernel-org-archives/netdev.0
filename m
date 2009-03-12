From: Michal Schmidt <mschmidt@redhat.com>
Subject: Re: [PATCH] 8139cp: allow to set mac address on running device
Date: Thu, 12 Mar 2009 18:11:21 +0100
Message-ID: <20090312181121.79e297a2@brian.englab.brq.redhat.com>
References: <20090312162730.GA20153@psychotron.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, ivecera@redhat.com,
	jgarzik@pobox.com, davem@davemloft.net, netdev@vger.kernel.org
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757297AbZCLRLj@vger.kernel.org>
In-Reply-To: <20090312162730.GA20153@psychotron.englab.brq.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 12 Mar 2009 17:27:31 +0100
Jiri Pirko <jpirko@redhat.com> wrote:

> +	cpw32_f(MAC0 + 0, le32_to_cpu (*(__le32 *) (dev->dev_addr +
> 0)));
> +	cpw32_f(MAC0 + 4, le32_to_cpu (*(__le32 *) (dev->dev_addr +
> 4)));

You're writing to the card, so using *_to_cpu looks suspicious.

Michal
