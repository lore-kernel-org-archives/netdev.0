From: Jackson Corson <jcorson@iol.unh.edu>
Subject: Inquiry About How to Make Reliable Wireless Injection Using MAC80211
Date: Mon, 03 Jun 2013 16:00:10 -0400
Message-ID: <51ACF5CA.2060709@iol.unh.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Craig Chabot <cly34@iol.unh.edu>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod5og111.obsmtp.com ([64.18.0.22]:38608 "HELO
	exprod5og111.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1758767Ab3FCUHI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jun 2013 16:07:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi everyone,

My name is Jackson Corson and I work for the University of New Hampshire 
Interoperability Lab. I am currently working on a project to implement a 
wireless testing tool that can test our MAC 802.11n Conformance test 
suite. This tool is designed to send and receive any packet. It 
currently uses Lorcon2 to inject packets into mac80211. This has worked 
quite well except for the fact that radio tap headers are ignored and 
fields get set without me changing them. For example, the Duration/ID 
field always has a value even when set to 0. This means the tool only 
injects packets at basic rates and does not have reliable packet 
creation. My question to you guys is how can I get my tool to send 
packets quickly, reliably, and with the correct rates? I have tried 
several other methods besides lorcon to inject packets, with no 
difference. I have also edited to driver to no use the dynamic rate 
selection algorithm but that failed to work either. I am using an Ath9k 
card, linux 3.5.0.27-generic as my kernel, and Ubuntu 12.04LTS as my OS. 
I have tried several other wireless cards as well with the same result.

Thanks,

-- 
Jackson Corson
UNH-IOL Wireless Consortium
