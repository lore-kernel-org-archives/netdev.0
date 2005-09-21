From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] [NET] socket.c: zero socket addresses
	before use.
Date: Wed, 21 Sep 2005 00:13:21 -0700 (PDT)
Message-ID: <20050921.001321.78997430.davem@davemloft.net>
References: <m1ek7ulyt8.fsf@ebiederm.dsl.xmission.com>
	<20050912.154527.48978091.davem@davemloft.net>
	<m1hdcfhd40.fsf_-_@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: openib-general@openib.org, netdev@vger.kernel.org
Return-path: <openib-general-bounces@openib.org>
To: ebiederm@xmission.com
In-Reply-To: <m1hdcfhd40.fsf_-_@ebiederm.dsl.xmission.com>
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

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Tue, 20 Sep 2005 11:18:23 -0600

> Dave I don't know if this is part of what you want but
> zeroing the socket address buffer before use seem to be implied
> by what you were asking for.   So here is an additional patch
> to implement that.
> 
> This is a paranoid precaution to guard against accidental
> information leaks to user space or other consumers/producers
> may fail to properly fail to set or read the hardware
> address length. af_packet over ethernet has had at least
> has one small but in this respect.

I think this patch might be a bit overkill, but thanks for cooking it
up.  I'm willing to be convinced otherwise though :-)
