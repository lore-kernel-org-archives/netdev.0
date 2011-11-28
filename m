From: Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>
Subject: Issues with openflow protocol WAS(RE: [GIT PULL v2] Open
	vSwitch
Date: Mon, 28 Nov 2011 09:07:10 -0500
Message-ID: <1322489230.7338.71.camel@mojatatu>
References: <20111123075433.GA7928@gondor.apana.org.au>
	<1322050976.2039.125.camel@mojatatu>
	<20111128130409.GB16828@gondor.apana.org.au>
	<0199E0D51A61344794750DC57738F58E7586A74137@GVW1118EXC.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: "Fischer, Anna" <anna.fischer-VXdhtT5mjnY@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <0199E0D51A61344794750DC57738F58E7586A74137-1IhDuF6AwYvulpxXP3Mx0dVKv6DIAtwysh7EHKopUjU@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 2011-11-28 at 13:54 +0000, Fischer, Anna wrote:

> Yes, I mentioned this months ago, and I am surprised this critical 
> issue has never been picked up on and addressed. With a flaw like 
> this there is no chance this component can be used in any serious 
> virtualization deployment where different customers share the same physical server.
>
> The path up to user-space needs to be designed in a multi-queue fashion, so that 
> each vPort has its own queue up to user-space. Ideally those queues also need to 
> be rate controlled in some form, so that no DoS is possible.

Good - more folks scrutinizing openflow ;->
That would resolve the kernel->user if in addition you then add
prioritization of those queues. 
But even then also the same problem exists with open flow in the 
northbound direction towards the external controller where
there is a single (TCP) socket.

cheers,
jamal
