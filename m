From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: CONFIG_IRQBALANCE for AMD64?
Date: Fri, 28 May 2004 17:45:24 -0400
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <40B7B2F4.7080704@pobox.com>
References: <7F740D512C7C1046AB53446D372001730182BAE2@scsmsx402.amr.corp.intel.com> <40B7797F.2090204@pobox.com> <17750000.1085766378@flay> <20040528175724.GC9898@devserv.devel.redhat.com> <40B7984E.7040208@us.ibm.com> <40B799EB.8060000@pobox.com> <40B79DB0.6090209@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Arjan van de Ven <arjanv@redhat.com>,
	"Martin J. Bligh" <mbligh@aracnet.com>,
	"Nakajima, Jun" <jun.nakajima@intel.com>,
	Andrew Morton <akpm@osdl.org>,
	Anton Blanchard <anton@samba.org>,
	linux-kernel@vger.kernel.org, Netdev <netdev@oss.sgi.com>
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org-S263995AbUE1Vuk@vger.kernel.org>
To: Nivedita Singhvi <niv@us.ibm.com>
In-Reply-To: <40B79DB0.6090209@us.ibm.com>
List-Id: netdev.vger.kernel.org

Long term, when NIC hardware is more advanced, we'll want something that 
divides sockets/connections/etc. into per-CPU clusters...  something 
that's friendly to both SMP and NUMA+SMP configurations.

Or if enterprising companies get a clue, and open their NIC firmware, I 
bet we could do this now.

	Jeff
