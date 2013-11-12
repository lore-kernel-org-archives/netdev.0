From: srinivas kandagatla <srinivas.kandagatla@st.com>
Subject: Re: [PATCH RFC 07/10] PM / wakeup : Introduce device_child_may_wakeup
Date: Tue, 12 Nov 2013 14:09:01 +0000
Message-ID: <5282367D.1090705@st.com>
References: <1384264311-7308-1-git-send-email-srinivas.kandagatla@st.com> <1384264377-7609-1-git-send-email-srinivas.kandagatla@st.com> <4093206.klj58BXQv3@vostro.rjw.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <linux-arm-kernel@lists.infradead.org>, <netdev@vger.kernel.org>,
	Rob Herring <rob.herring@calxeda.com>,
	Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Stephen Warren <swarren@wwwdotorg.org>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Rob Landley <rob@landley.net>,
	Russell King <linux@arm.linux.org.uk>,
	Stuart Menefy <stuart.menefy@st.com>,
	Pavel Machek <pavel@ucw.cz>, Len Brown <len.brown@intel.com>,
	<stephen.gallimore@st.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	Grant Likely <grant.likely@linaro.org>,
	<devicetree@vger.kernel.org>, <linux-doc@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <kernel@stlinux.com>,
	<linux-pm@vger.kernel.org>
To: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <4093206.klj58BXQv3@vostro.rjw.lan>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/11/13 14:20, Rafael J. Wysocki wrote:
>>  
>> > +/* callback for device_child_may_wakeup */
>> > +static int __device_child_may_wakeup(struct device *dev, void *c)
>> > +{
>> > +	return device_may_wakeup(dev);
>> > +}
> This doesn't have anything to do with children in principle, so please call
> it differently.  Something like device_may_wakeup_cb() would work for me (and
> then you may not need the comment even).

Thanks Rafael, I will fix this in next version.
> 
> Thanks!
> 
>> > +
>> > +/**

