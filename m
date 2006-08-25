From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 0/4] VM deadlock prevention -v5
Date: Fri, 25 Aug 2006 08:51:09 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0608250849480.9083@schroedinger.engr.sgi.com>
References: <20060825153946.24271.42758.sendpatchset@twins>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Indan Zupancic <indan@nul.nu>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Daniel Phillips <phillips@google.com>,
	Rik van Riel <riel@redhat.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from omx1-ext.sgi.com ([192.48.179.11]:38121 "EHLO
	omx1.americas.sgi.com") by vger.kernel.org with ESMTP
	id S1422867AbWHYPve (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Aug 2006 11:51:34 -0400
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20060825153946.24271.42758.sendpatchset@twins>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 25 Aug 2006, Peter Zijlstra wrote:

> The basic premises is that network sockets serving the VM need undisturbed
> functionality in the face of severe memory shortage.
> 
> This patch-set provides the framework to provide this.

Hmmm.. Is it not possible to avoid the memory pools by 
guaranteeing that a certain number of page is easily reclaimable?
