From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next 1/3 v6] net: ether: Add support for
 multiplexing and aggregation type
Date: Mon, 21 Aug 2017 15:00:14 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DD005CC8C@AcuExch.aculab.com>
References: <1503120931-30092-1-git-send-email-subashab@codeaurora.org>
        <1503120931-30092-2-git-send-email-subashab@codeaurora.org>
        <6dd2e0b7-51ec-18a3-07fb-3952a114b89a@mojatatu.com>
 <20170820.151207.1229905735989482121.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "subashab@codeaurora.org" <subashab@codeaurora.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "fengguang.wu@intel.com" <fengguang.wu@intel.com>,
        "dcbw@redhat.com" <dcbw@redhat.com>,
        "jiri@resnulli.us" <jiri@resnulli.us>,
        "stephen@networkplumber.org" <stephen@networkplumber.org>,
        "marcel@holtmann.org" <marcel@holtmann.org>
To: 'David Miller' <davem@davemloft.net>,
        "jhs@mojatatu.com" <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.192]:57895 "EHLO
        smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753245AbdHUPAV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 21 Aug 2017 11:00:21 -0400
In-Reply-To: <20170820.151207.1229905735989482121.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller
> Sent: 20 August 2017 23:12
> From: Jamal Hadi Salim <jhs@mojatatu.com>
> Date: Sun, 20 Aug 2017 14:18:03 -0400
> 
> > On 17-08-19 01:35 AM, Subash Abhinov Kasiviswanathan wrote:
> >> Define the multiplexing and aggregation (MAP) ether type 0xDA1A. This
> >> is needed for receiving data in the MAP protocol like RMNET. This is
> >> not an officially registered ID.
> >> Signed-off-by: Subash Abhinov Kasiviswanathan
> >> <subashab@codeaurora.org>
> >> ---
> >>   include/uapi/linux/if_ether.h | 4 +++-
> >>   1 file changed, 3 insertions(+), 1 deletion(-)
> >> diff --git a/include/uapi/linux/if_ether.h
> >> b/include/uapi/linux/if_ether.h
> >> index 5bc9bfd..e80b03f 100644
> >> --- a/include/uapi/linux/if_ether.h
> >> +++ b/include/uapi/linux/if_ether.h
> >> @@ -104,7 +104,9 @@
> >>   #define ETH_P_QINQ3 0x9300 /* deprecated QinQ VLAN [ NOT AN OFFICIALLY
> >>   #REGISTERED ID ] */
> >>   #define ETH_P_EDSA 0xDADA /* Ethertype DSA [ NOT AN OFFICIALLY
> >>   #REGISTERED ID ] */
> >>   #define ETH_P_AF_IUCV 0xFBFB /* IBM af_iucv [ NOT AN OFFICIALLY
> >>   #REGISTERED ID ] */
> >> -
> >> +#define ETH_P_MAP 0xDA1A /* Multiplexing and Aggregation Protocol
> >> + * NOT AN OFFICIALLY REGISTERED ID ]
> >
> > You cant just arbitrarly assign yourself an ethertype.  The IEEE may
> > never issue you one - and if they do, it will likely not be the one
> > you want i.e above.
> >
> > If there is a way for you to make this a config option that is not
> > hardcoded to some default value then that would be the best approach
> > to take.
> 
> This may be a kind of a different situation, these ethertypes exist
> only internally in the kernel and never on the wire.
> 
> It's just controlling the demux on ethernet receive.
> 
> We have several IDs like this, and thus this addition is consistent
> with existing practice.

Are they ever put into ethernet packets?
If not then use values below 1500.

	David
