From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH][RFC/v1][11/12] Add InfiniBand
	Documentation files
Date: Mon, 22 Nov 2004 15:31:44 +0000
Message-ID: <20041122153144.GA4821@infradead.org>
References: <20041122714.taTI3zcdWo5JfuMd@topspin.com>
	<20041122714.AyIOvRY195EGFTaO@topspin.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org,
	openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
To: Roland Dreier <roland@topspin.com>
Content-Disposition: inline
In-Reply-To: <20041122714.AyIOvRY195EGFTaO@topspin.com>
List-Unsubscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=unsubscribe>
List-Archive: <http://openib.org/pipermail/openib-general>
List-Post: <mailto:openib-general@openib.org>
List-Help: <mailto:openib-general-request@openib.org?subject=help>
List-Subscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=subscribe>
Sender: openib-general-bounces@openib.org
Errors-To: openib-general-bounces@openib.org
List-Id: netdev.vger.kernel.org

> +  When the IPoIB driver is loaded, it creates one interface for each
> +  port using the P_Key at index 0.  To create an interface with a
> +  different P_Key, write the desired P_Key into the main interface's
> +  /sys/class/net/<intf name>/create_child file.  For example:
> +
> +    echo 0x8001 > /sys/class/net/ib0/create_child
> +
> +  This will create an interface named ib0.8001 with P_Key 0x8001.  To
> +  remove a subinterface, use the "delete_child" file:
> +
> +    echo 0x8001 > /sys/class/net/ib0/delete_child
> +
> +  The P_Key for any interface is given by the "pkey" file, and the
> +  main interface for a subinterface is in "parent."

Any reason this doesn't use an interface similar to the normal vlan code?

And what is a P_Key?
