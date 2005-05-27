From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] e1000: NUMA aware allocation of descriptors V2
Date: Fri, 27 May 2005 16:25:28 -0700
Message-ID: <20050527162528.2ba5113e.akpm@osdl.org>
References: <Pine.LNX.4.62.0505171854490.20408@graphe.net>
	<20050517190343.2e57fdd7.akpm@osdl.org>
	<Pine.LNX.4.62.0505171941340.21153@graphe.net>
	<20050517.195703.104034854.davem@davemloft.net>
	<Pine.LNX.4.62.0505172125210.22920@graphe.net>
	<20050517215845.2f87be2f.akpm@osdl.org>
	<5fc59ff305051808558f1ce59@mail.gmail.com>
	<20050518134250.3ee2703f.akpm@osdl.org>
	<Pine.LNX.4.62.0505271450200.25909@graphe.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ganesh.venkatesan@gmail.com, davem@davemloft.net,
	linux-kernel@vger.kernel.org, netdev@oss.sgi.com, shai@scalex86.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S262654AbVE0XYx@vger.kernel.org>
To: Christoph Lameter <christoph@lameter.com>
In-Reply-To: <Pine.LNX.4.62.0505271450200.25909@graphe.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Christoph Lameter <christoph@lameter.com> wrote:
>
> NUMA awareness for the e1000 driver. Allocate tx and rx descriptors
> on the node of the device.
> 
> It is safe to replace vmalloc by kmalloc node since only the descriptors
> are allocated in a NUMA aware way. These will not be so large that the
> use of vmalloc becomes necesssary.

Really?  That's probably OK with the default number of tx descriptors, but
that number can be made arbitrarily large with a module parameter.

Could you please work this with the e1000 developers?
