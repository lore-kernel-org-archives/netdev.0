From: yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org (YAMAMOTO Takashi)
Subject: Re: [PATCH v2.56] datapath: Add basic MPLS support to
 kernel
Date: Fri, 25 Apr 2014 17:06:39 +0900 (JST)
Message-ID: <20140425080639.DDFA371E74@kuma.localdomain>
References: <20140424232441.GA6282@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, rkerur-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: Your message of "Fri, 25 Apr 2014 08:24:43 +0900"
 <20140424232441.GA6282-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Sender: "dev" <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

> On Thu, Apr 24, 2014 at 05:57:29PM +0900, YAMAMOTO Takashi wrote:
>> hi,
>> 
>> > + * Due to the sample action there may be multiple possible eth types.
>> > + * In order to correctly validate actions all possible types are tracked
>> > + * and verified. This is done using struct eth_types.
>> 
>> is there any real-world use cases of these actions inside a sample?
>> otherwise, how about just rejecting such combinations?
>> it doesn't seem to worth the code complexity to me.
>> (sorry if it has been already discussed.  it's the first time for me
>> to seriously read this long-lived patch.)
> 
> Good point, the code is rather complex.
> 
> My understanding is that it comes into effect in the case
> of sflow or ipfix being configured on the bridge. I tend
> to think these are real-world use-cases, though that thinking
> is by no means fixed.
> 
> My reading of the code is that in the case of sflow and ipfix a single
> sample rule appears at the beginning of the flow. And that it may be
> possible to replace the code that you are referring to with something
> simpler to handle these cases.

it seems that they put only a userland action inside a sample.
it's what i expected from its name "sample".

> 
> My understanding is that the code you are referring to also comes into
> effect when a sample action (a Nicira extension) is used directly in a
> rule.  I am less sure that this is a real-world case but the complex logic
> you are referring to should to handle this use-case.

probably nicira folks can clarify?

YAMAMOTO Takashi
