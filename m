From: "David S. Miller" <davem@redhat.com>
Subject: Re: IPsecv6 integrity failures not dropped
Date: Fri, 18 Apr 2003 14:10:14 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030418.141014.17269641.davem@redhat.com>
References: <200304182017.h3IKH4ng019821@faith.austin.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: latten@austin.ibm.com
In-Reply-To: <200304182017.h3IKH4ng019821@faith.austin.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: latten@austin.ibm.com
   Date: Fri, 18 Apr 2003 15:17:04 -0500

   I modified ah6_input() and esp6_input() to return zero instead of -EINVAL
   in the fix below. I tested it and it works.
   
   Please let me know if this is ok. 

I think it would be better if ipv6's upper-layer interface worked
like ipv4's.  ie. a < 0 return value means:

	next_proto =- ret;
	goto resubmit;

The less that is different between ipv4/ipv6 the better.
