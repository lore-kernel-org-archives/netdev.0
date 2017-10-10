From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH v2 net-next 1/2] net: dsa: lan9303: Move tag setup to new lan9303_setup_tagging
Date: Tue, 10 Oct 2017 11:51:37 -0400
Message-ID: <87zi8zhugm.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20171010124953.386-1-privat@egil-hjelmeland.no> <20171010124953.386-2-privat@egil-hjelmeland.no> <9235D6609DB808459E95D78E17F2E43D40B48C3D@CHN-SV-EXMX02.mchp-main.com> <2d03fb99-fd1c-9a0b-3274-eda605c3eb2d@egil-hjelmeland.no>
Mime-Version: 1.0
Content-Type: text/plain
To: Egil Hjelmeland <privat@egil-hjelmeland.no>,
        Woojung.Huh@microchip.com, andrew@lunn.ch, f.fainelli@gmail.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <2d03fb99-fd1c-9a0b-3274-eda605c3eb2d@egil-hjelmeland.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Egil,

Egil Hjelmeland <privat@egil-hjelmeland.no> writes:

>>> +	val = LAN9303_BM_EGRSS_PORT_TYPE_SPECIAL_TAG_PORT0;
>>> +	return lan9303_write_switch_reg(chip,
>>> LAN9303_BM_EGRSS_PORT_TYPE, val);
>> Specific reason to use val then using LAN9303_BM_EGRSS_PORT_TYPE_SPECIAL_TAG_PORT0
>> like previous line?
>> 
> Specific reason was to please a reviewer that did not like my
> indenting in first version. I did not agree with him, but since
> nobody else spoke up, I changed the code.

Your indentation was broken and did not respect the Kernel Coding
Style. Using a temporary variable here ensures you respect both the
80-char limit and the vertical alignment on opening parenthesis.

You'd like to use ./scripts/checkpatch.pl before submitting patches.


Thanks,

        Vivien
