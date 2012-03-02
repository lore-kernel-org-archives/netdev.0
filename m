From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC PATCH v0 1/2] net: bridge: propagate FDB table into
 hardware
Date: Fri, 02 Mar 2012 08:20:45 -0500
Message-ID: <1330694445.2405.162.camel@mojatatu>
References: <20120209032206.32468.92296.stgit@jf-dev1-dcblab>
	 <20120208203627.035c6b0e@nehalam.linuxnetplumber.net>
	 <4F34042F.6090806@intel.com>
	 <20120209094047.3ea7aa56@nehalam.linuxnetplumber.net>
	 <4F3407F7.9000202@intel.com> <1328821894.2089.3.camel@mojatatu>
	 <4F347D96.2020806@intel.com> <4F3499BC.8020609@intel.com>
	 <1328887111.2075.43.camel@mojatatu> <4F39287F.6030204@intel.com>
	 <1329225526.2806.34.camel@mojatatu> <4F3AAE80.4040609@intel.com>
	 <1329315057.4158.15.camel@mojatatu> <4F3C5B44.7000608@intel.com>
	 <1329488932.2272.19.camel@mojatatu> <4F3E8A01.5000205@intel.com>
	 <1329568900.3027.0.camel@mojatatu> <4F4DAC26.4050108@intel.com>
	 <1330523779.18226.17.camel@mojatatu> <4F4E5FA4.4040506@intel.com>
	 <20120229095204.48885405@nehalam.linuxnetplumber.net>
	 <4F4E6C44.9070502@intel.com> <1330608980.6944.27.camel@mojatatu>
	 <4F4FF578.30000@intel.com>
Reply-To: jhs@mojatatu.com
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	bhutchings@solarflare.com, roprabhu@cisco.com,
	netdev@vger.kernel.org, mst@redhat.com, chrisw@redhat.com,
	davem@davemloft.net, gregory.v.rose@intel.com, kvm@vger.kernel.org,
	sri@us.ibm.com, kernel@wantstofly.org
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <4F4FF578.30000@intel.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2012-03-01 at 14:17 -0800, John Fastabend wrote:
> Hmm so I think what I'll do is this...
> 
>  both: ndm_flags = 0 
>  sw  : ndm_flags = NTF_SW_FDB
>  hw  : ndm_flags = NTF_HW_FDB
>
> Then current tools will work with embedded bridges and software
> bridges
> with the interesting case being when a port supporting an offloaded
> FDB is attached to a SW bridge. Doing both in this case seems to be a
> reasonable default to me.

Looks good, although it seems like no backward compat is broken, it
feels like the default should be whats goin on today i.e s/ware only.
IOW, I would make that the 0.

cheers,
jamal

