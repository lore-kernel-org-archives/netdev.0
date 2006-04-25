From: Michal Schmidt <xschmi00@stud.feec.vutbr.cz>
Subject: Re: is it a backwards compatability catch-22?
Date: Tue, 25 Apr 2006 21:10:46 +0200
Message-ID: <444E7436.1000403@stud.feec.vutbr.cz>
References: <444D6396.4010004@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Network Development list <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tron.kn.vutbr.cz ([147.229.191.152]:16908 "EHLO
	tron.kn.vutbr.cz") by vger.kernel.org with ESMTP id S932294AbWDYTK4
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Apr 2006 15:10:56 -0400
To: Rick Jones <rick.jones2@hp.com>
In-Reply-To: <444D6396.4010004@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rick Jones wrote:
> lumber:~# cat /etc/udev/rules.d/010_netinterfaces.rules
> KERNEL="eth*",SYSFS{address}=="00:30:6e:4c:27:3c", NAME="eth0"
> KERNEL="eth*",SYSFS{address}=="00:30:6e:4c:27:3d", NAME="eth1"
> KERNEL="eth*",SYSFS{address}=="00:12:79:9e:0e:d2", NAME="eth2"
> KERNEL="eth*",SYSFS{address}=="00:12:79:9e:0e:d3", NAME="eth3"
> KERNEL="eth*",SYSFS{address}=="00:0c:fc:00:08:71", NAME="eth4"
        ^^^
BTW, you should use "==" here instead of "=". Otherwise the rules will 
break with newer udev versions which behave strictly in this regard.

Michal
