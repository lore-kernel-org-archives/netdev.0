From: "Fischer, Anna" <anna.fischer-VXdhtT5mjnY@public.gmane.org>
Subject: Re: Issues with openflow protocol WAS(RE: [GIT PULL v2]
 Open vSwitch
Date: Mon, 28 Nov 2011 18:54:22 +0000
Message-ID: <0199E0D51A61344794750DC57738F58E7586A7435F@GVW1118EXC.americas.hpqcorp.net>
References: <20111123075433.GA7928@gondor.apana.org.au>
	<1322050976.2039.125.camel@mojatatu>
	<20111128130409.GB16828@gondor.apana.org.au>
	<0199E0D51A61344794750DC57738F58E7586A74137@GVW1118EXC.americas.hpqcorp.net>
	<1322489230.7338.71.camel@mojatatu>
	<20124540-D566-41B0-B86F-0BCA19B948AA@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>, David-/PVsmBQoxgPKo9QCiBeYKEEOCMrvLtNR@public.gmane.org
To: Justin Pettit <jpettit-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>, Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <20124540-D566-41B0-B86F-0BCA19B948AA-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Content-Language: en-US
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

> Subject: Re: [ovs-dev] Issues with openflow protocol WAS(RE: [GIT PULL
> v2] Open vSwitch
> 
> On Nov 28, 2011, at 6:07 AM, Jamal Hadi Salim wrote:
> 
> > On Mon, 2011-11-28 at 13:54 +0000, Fischer, Anna wrote:
> >
> >> Yes, I mentioned this months ago, and I am surprised this critical
> >> issue has never been picked up on and addressed. With a flaw like
> >> this there is no chance this component can be used in any serious
> >> virtualization deployment where different customers share the same
> physical server.
> >>
> >> The path up to user-space needs to be designed in a multi-queue
> fashion, so that
> >> each vPort has its own queue up to user-space. Ideally those queues
> also need to
> >> be rate controlled in some form, so that no DoS is possible.
> >
> > Good - more folks scrutinizing openflow ;->
> 
> I realize you chair an IETF standard with overlapping goals with
> OpenFlow (ForCES), so you may have strong opinions about its design.
> However, that's not relevant to this discussion, since OpenFlow's
> design
> has nothing to do with the discussion being held here in regards to
> Open
> vSwitch.  OpenFlow is just a bullet point--although an important one--
> in
> a large set of features that Open vSwitch provides.  Its design is such
> that it should be fairly easy to include new control protocols;
> OpenFlow
> is just a library in Open vSwitch.  If you have issues with OpenFlow,
> those would be better directed to the ONF or one of the OpenFlow
> mailing
> lists.

True, and I was not interested in OpenFlow rate controlling but purely in rate controlling within the kernel for what goes up to user-space. And you addressed that with individual queues per vPort, so that solves my issues.
