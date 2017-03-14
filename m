From: Doug Berger <opendmb@gmail.com>
Subject: Re: [PATCH net-next 09/12] net: bcmgenet: return EOPNOTSUPP for
 unknown ioctl commands
Date: Tue, 14 Mar 2017 10:31:00 -0700
Message-ID: <07283b51-ef2b-92f8-88c2-3803c6f9c81b@gmail.com>
References: <20170314004142.4746-1-opendmb@gmail.com>
 <20170314004142.4746-10-opendmb@gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6DCFFB052E@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: "robh+dt@kernel.org" <robh+dt@kernel.org>,
        "mark.rutland@arm.com" <mark.rutland@arm.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "rafal@milecki.pl" <rafal@milecki.pl>,
        "xow@google.com" <xow@google.com>,
        "joel@jms.id.au" <joel@jms.id.au>,
        "jon.mason@broadcom.com" <jon.mason@broadcom.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "pgynther@google.com" <pgynther@google.com>,
        "jaedon.shin@gmail.com" <jaedon.shin@gmail.com>
To: David Laight <David.Laight@ACULAB.COM>,
        "f.fainelli@gmail.com" <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DCFFB052E@AcuExch.aculab.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/14/2017 04:04 AM, David Laight wrote:
> From: Doug Berger
>> Sent: 14 March 2017 00:42
>> This commit changes the ioctl handling behavior to return the
>> EOPNOTSUPP error code instead of the EINVAL error code when an
>> unknown ioctl command value is detected.
>>
>> It also removes some redundant parsing of the ioctl command value
>> and allows the SIOCSHWTSTAMP value to be handled.
> 
> A better description would seem to be:
> Remove checks on ioctl command and just forward all ioctl requests
> to phy_mii_ioctl().
That is a good description of the code change, but I felt that was
clearly conveyed by the patch content.  I thought it would be a better
use of the comment to describe the more subtle functional change that
might be less clear.

> 
> I also thought the 'generic' response to an unknown ioctl command
> was ENOTTY.
and I think it probably helped solicit this feedback :).  I would have
thought that error makes more sense if there is no ioctl handler, but I
will definitely look into it.

Thanks for the feedback,
    Doug
