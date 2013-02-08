From: "Arend van Spriel" <arend@broadcom.com>
Subject: Re: Wifi basics documents
Date: Fri, 8 Feb 2013 11:20:40 +0100
Message-ID: <5114D178.10007@broadcom.com>
References: <CAHT=_ri0JBrbPfWJrzjYR4eNDDW9ygMkJSDU4vJXEfh_STLK9g@mail.gmail.com>
 <5114B881.9000100@broadcom.com>
 <CAGmqTTSovcse3k4kv5o=+K6adAb672O5nJ=nXfZmc=d36gMSJw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Onteddu Slreddy" <slreddy88@gmail.com>,
	netdev <netdev@vger.kernel.org>, linux-can@vger.kernel.org,
	linux-kernel@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	linux-usb@vger.kernel.org, linux-wireless@vger.kernel.org,
	ath9k-devel@lists.ath9k.org, wil6210@qca.qualcomm.com,
	brcm80211-dev-list@broadcom.com,
	devicetree-discuss <devicetree-discuss@lists.ozlabs.org>
To: "sl reddy" <slreddyforneobux@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAGmqTTSovcse3k4kv5o=+K6adAb672O5nJ=nXfZmc=d36gMSJw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/08/2013 10:53 AM, sl reddy wrote:
> any successions will be helpful for me

My *suggestion* would be:

http://wireless.kernel.org/en/developers/Documentation

For what it is worth, below is some terrible ascii art.

Gr. AvS

Fullmac model:

                 user-space (libnl)
                  |
+----------+      v
| cfg80211 |------o nl80211 api
+----------+
     ^
     |
     v
+----------+
| fullmac  |------o netdev
| driver   |
+----------+

Softmac model:

                 user-space (libnl)
                  |
+----------+      v
| cfg80211 |------o nl80211 api
+----------+
     ^
     |
     v
+----------+
| mac80211 |------o netdev
+----------+
     ^
     |
     v
+----------+
| softmac  |
| driver   |
+----------+
