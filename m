From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 3/7] net: dsa: get port type at parse time
Date: Mon, 30 Oct 2017 11:46:57 -0700
Message-ID: <0e8c7922-67c4-5fe2-339a-cf0c5c735d7c@gmail.com>
References: <20171027195519.5931-1-vivien.didelot@savoirfairelinux.com>
 <20171027195519.5931-4-vivien.didelot@savoirfairelinux.com>
 <d45c07a3-940b-e2f3-8011-e44ca074a502@gmail.com>
 <87she079tq.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87she079tq.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/30/2017 11:46 AM, Vivien Didelot wrote:
> Hi Florian,
> 
> Florian Fainelli <f.fainelli@gmail.com> writes:
> 
>> Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
>>
>> One nit below:
>>
>>>  static int dsa_port_parse_of(struct dsa_port *dp, struct device_node *dn)
>>>  {
>>> +	struct device_node *ethernet = of_parse_phandle(dn, "ethernet", 0);
>>> +	struct device_node *link = of_parse_phandle(dn, "link", 0);
>>> +
>>> +	if (ethernet) {
>>> +		dp->type = DSA_PORT_TYPE_CPU;
>>> +	} else if (link) {
>>> +		dp->type = DSA_PORT_TYPE_DSA;
>>> +	} else {
>>> +		dp->type = DSA_PORT_TYPE_USER;
>>> +	}
>>> +
>>
>> The curly braces are probably not necessary since all of these are
>> single line statements.
> 
> I didn't mention it in the commit message because it was obvious that
> the next patches will extend these condition arms.

Fair enough then ;)
-- 
Florian
