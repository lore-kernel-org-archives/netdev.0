From: Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>
Subject: Re: second wave of netlink extended ACK reporting
Date: Sun, 16 Apr 2017 10:48:52 -0400
Message-ID: <280d0c61-4506-f721-1536-4afb2daabef8@mojatatu.com>
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
 <1492111480.29526.7.camel@sipsolutions.net>
 <826de765-dd18-f6a3-8e37-7b55398ad99b@mojatatu.com>
 <c75ab5ec-d33e-256d-1222-590dd22c5b08@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org, Jiri Benc <jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
To: David Ahern <dsa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org>,
        Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
        nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org, Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>,
        Pravin Shelar <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>, dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <c75ab5ec-d33e-256d-1222-590dd22c5b08-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 17-04-16 10:45 AM, David Ahern wrote:
> On 4/16/17 8:40 AM, Jamal Hadi Salim wrote:
>>
>> Johannes or anybody else working on it?
>> i.e one which sends the extack to the bowels of callees
>> so we can return meaningful messages
>> example: rtnetlink::doit() or equivalent seems to be a candidate for
>> taking it as a param
>
> I have a patch for the first pass on rtnetlink doit path. plumbs the
> extack parameter and covers the nlmsg_parse case.  I'll send it once
> Johannes' patches go in.
>

Excellent. His patches seem to be in. Seems
commit ce07183282975026716107d36fd3f5f93de76668
is a good point?

cheers,
jamal
