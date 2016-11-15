From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH V2] mac80211: Ignore VHT IE from peer with wrong
 rx_mcs_map
Date: Tue, 15 Nov 2016 14:20:12 +0100
Message-ID: <1479216012.12007.27.camel@sipsolutions.net>
References: <1478077466-4308-1-git-send-email-filip.matusiak@tieto.com>
         (sfid-20161102_100438_908657_9F74D2B9)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: marek.kwaczynski@tieto.com, davem@davemloft.net,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Filip Matusiak <filip.matusiak@tieto.com>,
        linux-wireless@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1478077466-4308-1-git-send-email-filip.matusiak@tieto.com> (sfid-20161102_100438_908657_9F74D2B9)
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2016-11-02 at 10:04 +0100, Filip Matusiak wrote:
> This is a workaround for VHT-enabled STAs which break the spec
> and have the VHT-MCS Rx map filled in with value 3 for all eight
> spacial streams, an example is AR9462 in AP mode.
> 
> As per spec, in section 22.1.1 Introduction to the VHT PHY
> A VHT STA shall support at least single spactial stream VHT-MCSs
> 0 to 7 (transmit and receive) in all supported channel widths.
> 
> Some devices in STA mode will get firmware assert when trying to
> associate, examples are QCA9377 & QCA6174.
> 
> Packet example of broken VHT Cap IE of AR9462:
> 
> [...]

Applied, thanks.

johannes
