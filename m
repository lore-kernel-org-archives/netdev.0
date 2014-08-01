From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next 1/3] lib: Resizable, Scalable, Concurrent Hash
 Table
Date: Fri, 1 Aug 2014 11:33:24 +0100
Message-ID: <20140801103324.GB7331@casper.infradead.org>
References: <cover.1406882738.git.tgraf@suug.ch>
 <15a766adefc269dd26001474e9b67dbbd0d5bc82.1406882738.git.tgraf@suug.ch>
 <53DB656C.9000907@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kaber@trash.net,
	paulmck@linux.vnet.ibm.com, josh@joshtriplett.org,
	challa@noironetworks.com, walpole@cs.pdx.edu, dev@openvswitch.org,
	tklauser@distanz.ch, netfilter-devel@vger.kernel.org
To: Nikolay Aleksandrov <nikolay@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <53DB656C.9000907@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/01/14 at 12:01pm, Nikolay Aleksandrov wrote:
> I see that ht->shift is being set but then ht is being zeroed, wouldn't this
> allow for the table to double ilog2(tbl->size) times more ?

Absolutely, thanks for catching this!
