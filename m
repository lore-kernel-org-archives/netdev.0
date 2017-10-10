From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next RFC 1/9] net: dsa: mv88e6xxx: add accessors for PTP/TAI registers
Date: Tue, 10 Oct 2017 09:59:39 -0400
Message-ID: <87376r6r3o.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <1506612341-18061-1-git-send-email-brandon.streiff@ni.com> <1506612341-18061-2-git-send-email-brandon.streiff@ni.com> <87o9puaisb.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Mime-Version: 1.0
Content-Type: text/plain
To: Brandon Streiff <brandon.streiff@ni.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:58310 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932176AbdJJN7l (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Oct 2017 09:59:41 -0400
In-Reply-To: <87o9puaisb.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Brandon,

Vivien Didelot <vivien.didelot@savoirfairelinux.com> writes:

> Brandon Streiff <brandon.streiff@ni.com> writes:
>
>> +	.port_ptp_read		= mv88e6352_port_ptp_read,
>> +	.port_ptp_write		= mv88e6352_port_ptp_write,
>> +	.ptp_read		= mv88e6352_ptp_read,
>> +	.ptp_write		= mv88e6352_ptp_write,
>> +	.tai_read		= mv88e6352_tai_read,
>> +	.tai_write		= mv88e6352_tai_write,
>
>> +	.port_ptp_read		= mv88e6390_port_ptp_read,
>> +	.port_ptp_write		= mv88e6390_port_ptp_write,
>> +	.ptp_read		= mv88e6390_ptp_read,
>> +	.ptp_write		= mv88e6390_ptp_write,
>> +	.tai_read		= mv88e6390_tai_read,
>> +	.tai_write		= mv88e6390_tai_write,
>
> Only nitpick: please keep the mv88e63{52,90}_g2_avb_ prefix here.
>
> Otherwise thanks for respecting the code organization, very clear patch:
>
> Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Also feel free to move the mv88e6*_g2_avb_ functions into a
global2_avb.c file.

Thank you,

      Vivien
