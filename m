From: Roland Dreier <roland@topspin.com>
Subject: Re: [PATCH][RFC/v1][11/12] Add InfiniBand
	Documentation files
Date: Mon, 22 Nov 2004 07:41:47 -0800
Message-ID: <52k6sdevr8.fsf@topspin.com>
References: <20041122714.taTI3zcdWo5JfuMd@topspin.com>
	<20041122714.AyIOvRY195EGFTaO@topspin.com>
	<20041122153144.GA4821@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org,
	openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
To: Christoph Hellwig <hch@infradead.org>
In-Reply-To: <20041122153144.GA4821@infradead.org> (Christoph Hellwig's
	message of "Mon, 22 Nov 2004 15:31:44 +0000")
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

    Christoph> Any reason this doesn't use an interface similar to the
    Christoph> normal vlan code?

The normal vlan code uses an ioctl().  I thought a simple sysfs
interface would be more palatable than a new socket ioctl.

    Christoph> And what is a P_Key?

It is a 16-bit identifier carried by IB packets that says which
partition the packet is in.  End ports have P_Key tables that list
which partitions they are members of (a port can be a member of one or
more partitions, and can only receive packets from that partition).

 - Roland
