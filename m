From: "Olivier Crameri" <olivier.crameri@gmail.com>
Subject: Offloading features in VLAN interfaces
Date: Fri, 29 Sep 2006 17:21:44 -0700
Message-ID: <b54af0b00609291721u16acb2f1ma918adec9b2e782b@mail.gmail.com>
Reply-To: olivier.crameri@epfl.ch
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Yoshio Turner" <yoshiotu@hpl.hp.com>,
	"Santos, Jose Renato G" <joserenato.santos@hp.com>,
	"Janakiraman, John" <john.janakiraman@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.175]:22289 "EHLO
	ug-out-1314.google.com") by vger.kernel.org with ESMTP
	id S932365AbWI3AVq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Sep 2006 20:21:46 -0400
Received: by ug-out-1314.google.com with SMTP id o38so328011ugd
        for <netdev@vger.kernel.org>; Fri, 29 Sep 2006 17:21:44 -0700 (PDT)
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

after running some experiments, we realised that using VLAN support in
Linux caused some overhead. It turned out to be that the offloading
features of our NIC (tso, sg, checksum offloading) were not beeing
used.

After digging a little bit in the code, we realised that the VLAN code
did not set the features parameter of the net_device structure for the
virtual interface. Attached is a patch with a suggested solution to
this problem.

Please let us know if this is an acceptable patch.

Thanks,
Olivier Crameri, HP Labs
