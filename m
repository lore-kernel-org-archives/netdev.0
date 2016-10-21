From: Henri Roosen <henri.roosen@ginzinger.com>
Subject: commit-3ac72b7b63d5 breaks networking on iMX28
Date: Fri, 21 Oct 2016 11:19:50 +0200
Message-ID: <bc6aa851-3f52-2274-47dc-4933662648a1@ginzinger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 8BIT
To: <eric@nelint.com>, <fugang.duan@nxp.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.ginzinger.com ([31.193.165.229]:48413 "EHLO
        mail.ginzinger.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933608AbcJUJTz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Oct 2016 05:19:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Unfortunately commit-3ac72b7b63d5 "net: fec: align IP header in
hardware" breaks networking on an iMX28 system.

The commit seems valid for iMX6, where it is tested okay and solves the
unaligned accesses.

On iMX28 I still see unaligned accesses and networking is broken. Can
anyone confirm this?

Thanks,
Henri

________________________________

Ginzinger electronic systems GmbH
Gewerbegebiet Pirath 16
4952 Weng im Innkreis
www.ginzinger.com

Firmenbuchnummer: FN 364958d
Firmenbuchgericht: Ried im Innkreis
UID-Nr.: ATU66521089


________________________________

Kommende Events:

08.-11. November 2016: Besuchen Sie uns auf der electronica in München -> Halle B1 Stand 538
16. November 2016: Nachmittagsseminar mit unserem Partner Irlbacher zum Thema „Glas als innovatives Material für moderne HMI’s“
17. November 2016: Juristisches Seminar in Linz: Einsatz von Open Source-Software in der Industrie
06. Dezember 2016: Nachmittagsseminar mit unserem Partner sequality software engineering zum Thema Usability

>> Weitere Informationen zu diesen Veranstaltungen und Neuigkeiten aus der Elektronikbranche finden Sie auf www.ginzinger.com/techtalk
