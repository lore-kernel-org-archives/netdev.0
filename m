From: Christoph Lameter <christoph@lameter.com>
Subject: Re: [PATCH] NUMA aware allocation of transmit and receive buffers
 for e1000
Date: Fri, 27 May 2005 14:15:55 -0700 (PDT)
Message-ID: <Pine.LNX.4.62.0505271413560.25484@graphe.net>
References: <Pine.LNX.4.62.0505171854490.20408@graphe.net> <m1sm0l5lwa.fsf@muc.de>
 <428AF378.5020109@cosmosbay.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Andi Kleen <ak@muc.de>, netdev@oss.sgi.com, akpm@osdl.org,
        shai@scalex86.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Eric Dumazet <dada1@cosmosbay.com>
In-Reply-To: <428AF378.5020109@cosmosbay.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 18 May 2005, Eric Dumazet wrote:

> Related question, is pci_alloc_consistent() already NUMA aware ?

Nope. It also ultimately acquires memory via vmalloc.

pci_alloc_consistent will also need some rework to allocate memory 
consistent (well the name is coherent right?) with the node that the 
device is on. Second case of a need for a node aware vmalloc?
