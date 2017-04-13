From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH 1/5] netlink: extended ACK reporting
Date: Thu, 13 Apr 2017 21:24:40 +0200
Message-ID: <1492111480.29526.7.camel@sipsolutions.net>
References: <20170408174900.12820-1-johannes@sipsolutions.net>
	<20170408174900.12820-2-johannes@sipsolutions.net>
	<20170408183440.GA1900@nanopsycho>
	<1491676621.5800.24.camel@sipsolutions.net>
	<20170408184008.GB1900@nanopsycho>
	<990b5610-a894-b3d2-d3a7-536dfd25adb8@cumulusnetworks.com>
	<1491805089.2455.3.camel@sipsolutions.net>
	<c0b35e6e-e5cb-25f6-7ccf-eec33ba39f3b@6wind.com>
	<1492090170.29526.1.camel@sipsolutions.net>
	<28b0d93a-7e96-f7eb-b140-afc9ad429c30@6wind.com>
	(sfid-20170413_160541_831386_A409D7A6)
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>, pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org,
	Jiri Benc <jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
To: nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org, David Ahern <dsa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org>, Jiri
	Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>, Pravin Shelar <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>,
	dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Return-path: <ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <28b0d93a-7e96-f7eb-b140-afc9ad429c30-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>
	(sfid-20170413_160541_831386_A409D7A6)
List-Unsubscribe: <https://mail.openvswitch.org/mailman/options/ovs-dev>,
	<mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://mail.openvswitch.org/pipermail/ovs-dev/>
List-Post: <mailto:ovs-dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <https://mail.openvswitch.org/mailman/listinfo/ovs-dev>,
	<mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 2017-04-13 at 16:05 +0200, Nicolas Dichtel wrote:

> Sure. It was just to mention that attribute 0 exists somewhere.
> The other 0 attribute is OVS_TUNNEL_KEY_ATTR_ID.

That looks like some really awkward hand-grown parsing - with all these
"struct ovs_len_tbl" looking almost like a policy, but not using that
code?

Seems like something somebody should take a hard look at and see if it
can't use more standard infrastructure.

johannes
