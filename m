From: Sathya Perla <Sathya.Perla@Emulex.Com>
Subject: RE: [PATCH net-next v2] be2net: log link status
Date: Thu, 23 Apr 2015 06:31:40 +0000
Message-ID: <447118c7-cb5e-4e64-88cc-8205cadfaf5e@CMEXHTCAS2.ad.emulex.com>
References: <1429710210-7291-1-git-send-email-ivecera@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Subramanian Seetharaman <subbu.seetharaman@emulex.com>,
	"Ajit Kumar Khaparde" <Ajit.Khaparde@Emulex.Com>
To: Ivan Vecera <ivecera@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.emulex.com ([138.239.224.100]:3516 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751089AbbDWGcI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Apr 2015 02:32:08 -0400
In-Reply-To: <1429710210-7291-1-git-send-email-ivecera@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Ivan Vecera [mailto:ivecera@redhat.com]
> 
> The driver unlike other drivers does not log link state changes.
> 
> v2: added current link speed to log message
> 
Ivan, I disagree with the v2 change. I think your original intention
was just to log a message when the link goes up or down 
asynchronously (i.e., without any user intervention.)
After alerting the user, if the user wants to know other link
properties like speed, duplex etc then the ethtool cmd needs 
to be used; there is no need to log a message with those details.
