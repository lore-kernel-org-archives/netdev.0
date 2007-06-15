From: Keir Fraser <Keir.Fraser@cl.cam.ac.uk>
Subject: Re: [PATCH 0/4] [Net] Support accelerated network
	plugin modules
Date: Fri, 15 Jun 2007 13:29:58 +0100
Message-ID: <C29844D6.932D%Keir.Fraser@cl.cam.ac.uk>
References: <200706151421.01608.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xen-devel@lists.xensource.com,
	herbert@gondor.apana.org.au
To: Michael Buesch <mb@bu3sch.de>
Return-path: <xen-devel-bounces@lists.xensource.com>
In-Reply-To: <200706151421.01608.mb@bu3sch.de>
List-Unsubscribe: <http://lists.xensource.com/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xensource.com>
List-Help: <mailto:xen-devel-request@lists.xensource.com?subject=help>
List-Subscribe: <http://lists.xensource.com/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=subscribe>
Sender: xen-devel-bounces@lists.xensource.com
Errors-To: xen-devel-bounces@lists.xensource.com
List-Id: netdev.vger.kernel.org




On 15/6/07 13:21, "Michael Buesch" <mb@bu3sch.de> wrote:

>> True in general, but not the cases I've seen in this patchset, where 'foo'
>> is a predicate.
> 
> Ok, if foo is a variable containing an error code, it's
> better to return that error code. I assumed that foo is a
> variable containing some value (counter or something).

I mean specifically things like:
 if (be->accelerator == NULL)
    return 1;
 else
    return 0;

 K.
