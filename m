From: Keir Fraser <Keir.Fraser@cl.cam.ac.uk>
Subject: Re: [PATCH 0/4] [Net] Support accelerated network
	plugin modules
Date: Fri, 15 Jun 2007 13:20:34 +0100
Message-ID: <C29842A2.9328%Keir.Fraser@cl.cam.ac.uk>
References: <200706151411.31748.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xen-devel@lists.xensource.com,
	herbert@gondor.apana.org.au
To: Michael Buesch <mb@bu3sch.de>
Return-path: <xen-devel-bounces@lists.xensource.com>
In-Reply-To: <200706151411.31748.mb@bu3sch.de>
List-Unsubscribe: <http://lists.xensource.com/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xensource.com>
List-Help: <mailto:xen-devel-request@lists.xensource.com?subject=help>
List-Subscribe: <http://lists.xensource.com/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=subscribe>
Sender: xen-devel-bounces@lists.xensource.com
Errors-To: xen-devel-bounces@lists.xensource.com
List-Id: netdev.vger.kernel.org




On 15/6/07 13:11, "Michael Buesch" <mb@bu3sch.de> wrote:

>> No use of the following please:
>> If (foo) return 1; else return 0;
>> Is clearer as:
>> Return foo;
> 
> But it's not the same.
> return !!foo;
> would be the same. And yes, it does matter:

True in general, but not the cases I've seen in this patchset, where 'foo'
is a predicate.

 -- Keir
