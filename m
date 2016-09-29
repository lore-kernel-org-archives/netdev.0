From: "Jorgen S. Hansen" <jhansen@vmware.com>
Subject: Request for backport to 4.4 stable
Date: Thu, 29 Sep 2016 12:02:15 +0000
Message-ID: <BY2PR0501MB205628A0C48C3F674E31A482DACE0@BY2PR0501MB2056.namprd05.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ex13-edg-ou-001.vmware.com ([208.91.0.189]:50897 "EHLO
        EX13-EDG-OU-001.vmware.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1755338AbcI2MCT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Sep 2016 08:02:19 -0400
Received: from EX13-CAS-005.vmware.com (ex13-cas-005.vmware.com [10.113.191.55])
        by sc9-mailhost1.vmware.com (Postfix) with ESMTP id 2099A18389
        for <netdev@vger.kernel.org>; Thu, 29 Sep 2016 05:02:18 -0700 (PDT)
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

It would be great if the following commit could be backported to 4.4 stable=
. The commit fixes a bug that was introduced in 4.3 and fixed in 4.6. The b=
ug may cause wrongful termination of vSocket connections, if there is more =
than one active vSocket connection in a given VM. This affects VMware servi=
ces running inside VMs:

commit	8ab18d71de8b07d2c4d6f984b718418c09ea45c5=20

VSOCK: Detach QP check should filter out non matching QPs.

The check in vmci_transport_peer_detach_cb should only allow a
detach when the qp handle of the transport matches the one in
the detach message.

Thanks,
J=F8rgen
