From: Rob Herring <robh@kernel.org>
Subject: Re: [PATCH V3] net: emac: emac gigabit ethernet controller driver
Date: Sat, 30 Jan 2016 15:58:29 -0600
Message-ID: <CAL_JsqKWXnULfWkkvukWEzBBTG8JP+HKVg6WWejWcOA=p24tvQ@mail.gmail.com>
References: <1451440135-25771-1-git-send-email-gavidov@codeaurora.org>
 <20151231231039.GA8886@rob-hp-laptop> <56ABADEA.40801@codeaurora.org>
 <CAL_JsqLnJt+mdL==-qP-EJhMa2rA6i-AyDESj69wNVt7D5JJUQ@mail.gmail.com> <56ABCDB7.5080203@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Gilad Avidov <gavidov@codeaurora.org>,
	netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	linux-arm-msm <linux-arm-msm@vger.kernel.org>,
	Sagar Dharia <sdharia@codeaurora.org>, shankerd@codeaurora.org,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	vikrams@codeaurora.org, Christopher Covington <cov@codeaurora.org>
To: Timur Tabi <timur@codeaurora.org>
Return-path: <linux-arm-msm-owner@vger.kernel.org>
In-Reply-To: <56ABCDB7.5080203@codeaurora.org>
Sender: linux-arm-msm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 29, 2016 at 2:38 PM, Timur Tabi <timur@codeaurora.org> wrote:
> Rob Herring wrote:

[...]

>>>> Isn't this a user enabled feature if the h/w supports it?
>>>
>>>
>>>
>>> Is there a sysfs entry for that?  We were planning on having a similar
>>> ACPI
>>> property.
>>
>>
>> It would be in ethtool I think.
>
>
> Ah, this driver does not support ethtool yet.
>
> However, based on a cursory look of ethtool, it appears that there's only an
> option to query the current timestamp, but not actually enable/disable the
> feature.  The e1000e driver, for example, just forces the feature by default
> for various chips.  Is there any reason why we shouldn't enable it if the
> hardware supports it?

Probably not. You simply ignore the timestamp if you don't care. So
then why do you want a DT property?

Rob
