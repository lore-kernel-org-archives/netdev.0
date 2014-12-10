From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [RFC PATCH net-next 1/1] net: Support for switch port configuration
Date: Wed, 10 Dec 2014 09:03:51 -0800
Message-ID: <54887CF7.70708@gmail.com>
References: <C4896FB061E7DE4AAC93031BDCA044B104AC3257@IRSMSX108.ger.corp.intel.com> <20141210165018.GG1863@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Varlese, Marco" <marco.varlese@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	"Fastabend, John R" <john.r.fastabend@intel.com>,
	"roopa@cumulusnetworks.com" <roopa@cumulusnetworks.com>,
	"sfeldma@gmail.com" <sfeldma@gmail.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141210165018.GG1863@nanopsycho.orion>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/10/2014 08:50 AM, Jiri Pirko wrote:
> Wed, Dec 10, 2014 at 05:23:40PM CET, marco.varlese@intel.com wrote:
>> From: Marco Varlese <marco.varlese@intel.com>
>>
>> Switch hardware offers a list of attributes that are configurable
>> on a per port basis.
>> This patch provides a mechanism to configure switch ports by adding
>> an NDO for setting specific values to specific attributes.
>> There will be a separate patch that extends iproute2 to call the
>> new NDO.
>
>
> What are these attributes? Can you give some examples. I'm asking
> because there is a plan to pass generic attributes to switch ports
> replacing current specific ndo_switch_port_stp_update. In this case,
> bridge is setting that attribute.
>
> Is there need to set something directly from userspace or does it make
> rather sense to use involved bridge/ovs/bond ? I think that both will be
> needed.

+1

I think for many attributes it would be best to have both. The in
kernel callers and netlink userspace can use the same driver ndo_ops.

But then we don't _require_ any specific bridge/ovs/etc module. And we
may have some attributes that are not specific to any existing software
module. I'm guessing Marco has some examples of these.

[...]


-- 
John Fastabend         Intel Corporation
