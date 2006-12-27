From: "Nick Kossifidis" <mickflemm@gmail.com>
Subject: d80211 constants inside d80211_common.h
Date: Wed, 27 Dec 2006 10:32:52 +0200
Message-ID: <40f31dec0612270032g284160a8q2c6f190b4296a455@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David Kimdon" <david.kimdon@devicescape.com>,
	linville@tuxdriver.com, jbenc@suse.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.225]:63585 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753606AbWL0Icw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Dec 2006 03:32:52 -0500
Received: by wx-out-0506.google.com with SMTP id h27so4142988wxd
        for <netdev@vger.kernel.org>; Wed, 27 Dec 2006 00:32:52 -0800 (PST)
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ieee80211_msg_type, ieee80211_phytype and ieee80211_ssi_type should be
in capitals as they are constants and must not be mistaken for vars...


enum ieee80211_msg_type {
        IEEE80211_MSG_NORMAL            = 0,
        IEEE80211_MSG_TX_CALLBACK_ACK   = 1,
        IEEE80211_MSG_TX_CALLBACK_FAIL  = 2,
        IEEE80211_MSG_PASSIVE_SCAN      = 3,
        IEEE80211_MSG_WEP_FRAME_UNKNOWN_KEY = 4,
        IEEE80211_MSG_MICHAEL_MIC_FAIL  = 5,
        /* hole at 6, was monitor but never sent to userspace */
        IEEE80211_MSG_STA_NOT_ASSOC     = 7,
        IEEE80211_MSG_SET_AID_FOR_STA   = 8 /* used by Intersil MVC driver */,
        IEEE80211_MSG_KEY_THRESHOLD_NOTIFICATION = 9,
        IEEE80211_MSG_RADAR             = 11,
};


enum ieee80211_phytype {
        IEEE80211_PHYTYPE_FHSS_DOT11_97  = 1,
        IEEE80211_PHYTYPE_DSSS_DOT11_97  = 2,
        IEEE80211_PHYTYPE_IRBASEBAND     = 3,
        IEEE80211_PHYTYPE_DSSS_DOT11_B   = 4,
        IEEE80211_PHYTYPE_PBCC_DOT11_B   = 5,
        IEEE80211_PHYTYPE_OFDM_DOT11_G   = 6,
        IEEE80211_PHYTYPE_PBCC_DOT11_G   = 7,
        IEEE80211_PHYTYPE_OFDM_DOT11_A   = 8,
        IEEE80211_PHYTYPE_DSSS_DOT11_TURBOG = 255,
        IEEE80211_PHYTYPE_DSSS_DOT11_TURBO = 256,
};


enum ieee80211_ssi_type {
        IEEE80211_SSI_NONE = 0,
        IEEE80211_SSI_NORM = 1, /* normalized, 0-1000 */
        IEEE80211_SSI_DBM = 2,
        IEEE80211_SSI_RAW = 3, /* raw SSI */
};

I did a grep inside drivers/net/wireless/d80211/* and they are not
used yet in drivers. Can you plz fix it before drivers start using
them ?


Thanx for your time
Nick
