From: "Grandhi, Sainath" <sainath.grandhi@intel.com>
Subject: RE: [PATCHv2 7/7] IPVTAP: IP-VLAN based tap driver
Date: Thu, 19 Jan 2017 23:33:19 +0000
Message-ID: <2C5142675EC1274EAB6230F72F8DC95F28C6D4C1@ORSMSX113.amr.corp.intel.com>
References: <1484697786-50323-1-git-send-email-sainath.grandhi@intel.com>
        <1484697786-50323-8-git-send-email-sainath.grandhi@intel.com>
 <20170118.162842.2116473511473193362.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "mahesh@bandewar.net" <mahesh@bandewar.net>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170118.162842.2116473511473193362.davem@davemloft.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Wednesday, January 18, 2017 1:29 PM
> To: Grandhi, Sainath <sainath.grandhi@intel.com>
> Cc: netdev@vger.kernel.org; mahesh@bandewar.net; linux-
> kernel@vger.kernel.org
> Subject: Re: [PATCHv2 7/7] IPVTAP: IP-VLAN based tap driver
> 
> From: Sainath Grandhi <sainath.grandhi@intel.com>
> Date: Tue, 17 Jan 2017 16:03:06 -0800
> 
> > +static void ipvtap_count_tx_dropped(struct tap_dev *tap) {
> > +	struct ipvl_dev *vlan = (struct ipvl_dev *)container_of(tap, struct
> > +ipvtap_dev, tap);
>  ...
> > +static void ipvtap_count_rx_dropped(struct tap_dev *tap) {
> > +	struct ipvl_dev *vlan = (struct ipvl_dev *)container_of(tap, struct
> > +ipvtap_dev, tap);
>  ...
> > +static void ipvtap_update_features(struct tap_dev *tap,
> > +				   netdev_features_t features)
> > +{
> > +	struct ipvl_dev *vlan = (struct ipvl_dev *)container_of(tap, struct
> > +ipvtap_dev, tap);
> 
> More unnecessary casts, please remove.

Will take care of it in next revision. Thanks.
