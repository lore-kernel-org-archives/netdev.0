From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Re: [PATCH] tcp: fix ICMP-RTO war
Date: Sun, 24 Jan 2010 00:45:52 +0200
Message-ID: <201001240045.52846.denys@visp.net.lb>
References: <200912261703.49067.denys@visp.net.lb> <201001232337.19122.denys@visp.net.lb> <alpine.DEB.2.00.1001240007530.16552@melkinpaasi.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Damian Lukowski <damian@tvk.rwth-aachen.de>,
	Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: "Ilpo =?iso-8859-15?q?J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:33914 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750883Ab0AWWnv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jan 2010 17:43:51 -0500
In-Reply-To: <alpine.DEB.2.00.1001240007530.16552@melkinpaasi.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> 
> Cool, thanks for testing.
> 
> Dave, please send into stable too (besides net-2.6). If we want less strict
> state check we can continue playing with that in net-next, IMHO.
> 
Maybe better to wait. Sad news, got messages after while (before they was 
appearing  almost immediately on such load).

Here it is
[ 1253.821745] rto: 26496 (58 >> 3 + 200, 7) time: 953821 sent: 953283 pen: 1 
1006275 rem: 25958                                                                                 
[ 1278.791976] rto: 75264 (398 >> 3 + 245, 8) time: 978791 sent: 977749 pen: 1 
1097749 rem: 74222                                                                                
[ 1299.537823] lower bound violation: 0                                                                                                                                          
[ 1299.537846] rto: 200 (0 >> 3 + 0, 1) time: 999537 sent: 997699 pen: 1 
1009699 rem: 0                                                                                          
[ 1324.022158] rto: 11072 (2512 >> 3 + 1070, 3) time: 1024022 sent: 1023672 
pen: 1 1045816 rem: 10722                                                                            
[ 1333.112517] rto: 52992 (58 >> 3 + 200, 8) time: 1033112 sent: 1032771 pen: 
1 1138755 rem: 52651                                                                               
[ 1336.152839] rto: 11072 (2512 >> 3 + 1070, 3) time: 1036152 sent: 1034744 
pen: 1 1056888 rem: 9664                                                                             
[ 1426.219799] lower bound violation: 0                                                                                                                                          
[ 1426.219858] rto: 200 (0 >> 3 + 0, 1) time: 1126219 sent: 1125040 pen: 1 
1137040 rem: 0                                                                                        
[ 1429.235911] lower bound violation: 0                                                                                                                                          
[ 1429.235964] rto: 200 (0 >> 3 + 0, 4) time: 1129235 sent: 1129019 pen: 1 
1132219 rem: 0                                                                                        
[ 1432.279829] lower bound violation: 0                                                                                                                                          
[ 1432.279887] rto: 200 (0 >> 3 + 0, 7) time: 1132279 sent: 1132036 pen: 1 
1135236 rem: 0                                                                                        
[ 1435.311008] lower bound violation: 0                                                                                                                                          
[ 1435.311068] rto: 200 (0 >> 3 + 0, 10) time: 1135311 sent: 1135079 pen: 1 
1138279 rem: 0                                                                                       
[ 1479.029269] lower bound violation: 0                                                                                                                                          
[ 1479.029323] rto: 200 (0 >> 3 + 0, 9) time: 1179029 sent: 1174129 pen: 1 
1294129 rem: 0                                                                                        
[ 1483.851712] lower bound violation: 0                                                                                                                                          
[ 1483.851773] rto: 200 (0 >> 3 + 0, 12) time: 1183851 sent: 1181829 pen: 1 
1185029 rem: 0                                                                                       
[ 1483.851878] lower bound violation: 0                                                                                                                                          
[ 1483.851926] rto: 200 (0 >> 3 + 0, 12) time: 1183851 sent: 1183851 pen: 1 
1184251 rem: 200                                                                                     
[ 1483.852034] lower bound violation: 0                                                                                                                                          
[ 1483.852082] rto: 200 (0 >> 3 + 0, 11) time: 1183852 sent: 1183851 pen: 1 
1184052 rem: 199                                                                                     
[ 1486.934283] lower bound violation: 0                                                                                                                                          
[ 1486.934339] rto: 200 (0 >> 3 + 0, 14) time: 1186934 sent: 1186851 pen: 1 
1190051 rem: 117                                                                                     
[ 1486.934500] lower bound violation: 0                                                                                                                                          
[ 1486.934554] rto: 200 (0 >> 3 + 0, 13) time: 1186934 sent: 1186851 pen: 1 
1187051 rem: 117                                                                                     
[ 1490.170941] lower bound violation: 0                                                                                                                                          
[ 1490.171000] rto: 200 (0 >> 3 + 0, 16) time: 1190170 sent: 1189851 pen: 1 
1193051 rem: 0                                                                                       
[ 1490.171126] lower bound violation: 0                                                                                                                                          
[ 1490.171189] rto: 200 (0 >> 3 + 0, 16) time: 1190171 sent: 1190171 pen: 1 
1190571 rem: 200                                                                                     
[ 1490.171312] lower bound violation: 0                                                                                                                                          
[ 1490.171361] rto: 200 (0 >> 3 + 0, 15) time: 1190171 sent: 1190171 pen: 1 
1190371 rem: 200                                                                                     
[ 1494.052047] lower bound violation: 0                                                                                                                                          
[ 1494.052105] rto: 200 (0 >> 3 + 0, 18) time: 1194052 sent: 1193171 pen: 1 
1196371 rem: 0                                                                                       
[ 1494.052704] lower bound violation: 0                                                                                                                                          
[ 1494.052760] rto: 200 (0 >> 3 + 0, 18) time: 1194052 sent: 1194052 pen: 1 
1194452 rem: 200                                                                                     
[ 1497.678945] lower bound violation: 0                                                                                                                                          
[ 1497.679004] rto: 200 (0 >> 3 + 0, 21) time: 1197678 sent: 1197052 pen: 1 
1200252 rem: 0                                                                                       
[ 1497.679205] lower bound violation: 0                                                                                                                                          
[ 1497.679255] rto: 200 (0 >> 3 + 0, 21) time: 1197679 sent: 1197679 pen: 1 
1198079 rem: 200                                                                                     
[ 1497.679356] rto: 120000 (18111 >> 3 + 2633, 7) time: 1197679 sent: 1195423 
pen: 1 1315423 rem: 117744                                                                         
[ 1501.113733] lower bound violation: 0                                                                                                                                          
[ 1501.113786] rto: 200 (0 >> 3 + 0, 24) time: 1201113 sent: 1200679 pen: 1 
1203879 rem: 0                                                                                       
[ 1501.116064] rto: 120000 (17704 >> 3 + 4426, 8) time: 1201116 sent: 1198638 
pen: 1 1318638 rem: 117522                                                                         
[ 1501.116168] lower bound violation: 0                                                                                                                                          
[ 1501.116216] rto: 200 (0 >> 3 + 0, 24) time: 1201116 sent: 1201113 pen: 1 
1201513 rem: 197                                                                                     
[ 1504.165893] lower bound violation: 0                                                                                                                                          
[ 1504.165953] rto: 200 (0 >> 3 + 0, 27) time: 1204165 sent: 1204113 pen: 1 
1207313 rem: 148                                                                                     
[ 1504.168090] lower bound violation: 0                                                                                                                                          
[ 1504.168151] rto: 200 (0 >> 3 + 0, 26) time: 1204168 sent: 1204113 pen: 1 
1204313 rem: 145                                                                                     
[ 1504.168272] lower bound violation: 0                                                                                                                                          
[ 1504.168327] rto: 200 (0 >> 3 + 0, 25) time: 1204168 sent: 1204113 pen: 1 
1204313 rem: 145                                                                                     
[ 1507.280037] lower bound violation: 0                                                                                                                                          
[ 1507.280096] rto: 200 (0 >> 3 + 0, 28) time: 1207280 sent: 1207113 pen: 1 
1210313 rem: 33                                                                                      
[ 1507.280207] lower bound violation: 0                                                                                                                                          
[ 1507.280255] rto: 200 (0 >> 3 + 0, 27) time: 1207280 sent: 1207113 pen: 1 
1207313 rem: 33                                                                                      
[ 1510.974508] lower bound violation: 0                                                                                                                                          
[ 1510.974574] rto: 200 (0 >> 3 + 0, 30) time: 1210974 sent: 1210113 pen: 1 
1213313 rem: 0                                                                                       
[ 1510.974716] lower bound violation: 0                                                                                                                                          
[ 1510.974766] rto: 200 (0 >> 3 + 0, 30) time: 1210974 sent: 1210974 pen: 1 
1211374 rem: 200                                                                                     
[ 1514.436146] lower bound violation: 0                                                                                                                                          
[ 1514.436214] rto: 200 (0 >> 3 + 0, 33) time: 1214436 sent: 1213974 pen: 1 
1217174 rem: 0                                                                                       
[ 1514.436329] lower bound violation: 0                                                                                                                                          
[ 1514.436378] rto: 200 (0 >> 3 + 0, 33) time: 1214436 sent: 1214436 pen: 1 
1214836 rem: 200                                                                                     
[ 1514.436477] lower bound violation: 0                                                                                                                                          
[ 1514.436525] rto: 200 (0 >> 3 + 0, 32) time: 1214436 sent: 1214436 pen: 1 
1214636 rem: 200                                                                                     
[ 1517.516478] lower bound violation: 0                                                                                                                                          
[ 1517.516537] rto: 200 (0 >> 3 + 0, 35) time: 1217516 sent: 1217436 pen: 1 
1220636 rem: 120                                                                                     
[ 1517.520665] lower bound violation: 0                                                                                                                                          
[ 1517.520724] rto: 200 (0 >> 3 + 0, 34) time: 1217520 sent: 1217436 pen: 1 
1217636 rem: 116                                                                                     
[ 1517.520865] lower bound violation: 0                                                                                                                                          
[ 1517.520919] rto: 200 (0 >> 3 + 0, 33) time: 1217520 sent: 1217436 pen: 1 
1217636 rem: 116                                                                                     
[ 1520.579941] lower bound violation: 0                                                                                                                                          
[ 1520.580000] rto: 200 (0 >> 3 + 0, 36) time: 1220579 sent: 1220436 pen: 1 
1223636 rem: 57                                                                                      
[ 1520.580111] lower bound violation: 0                                                                                                                                          
[ 1520.580165] rto: 200 (0 >> 3 + 0, 35) time: 1220580 sent: 1220436 pen: 1 
1220637 rem: 56                                                                                      
[ 1520.580686] lower bound violation: 0                                                                                                                                          
[ 1520.580744] rto: 200 (0 >> 3 + 0, 34) time: 1220580 sent: 1220436 pen: 1 
1220636 rem: 56                                                                                      
[ 1523.693352] lower bound violation: 0                                                                                                                                          
[ 1523.693412] rto: 200 (0 >> 3 + 0, 37) time: 1223693 sent: 1223436 pen: 1 
1226636 rem: 0                                                                                       
[ 1523.693538] lower bound violation: 0                                                                                                                                          
[ 1523.693588] rto: 200 (0 >> 3 + 0, 37) time: 1223693 sent: 1223693 pen: 1 
1224093 rem: 200                                                                                     
[ 1523.693686] lower bound violation: 0                                                                                                                                          
[ 1523.693735] rto: 200 (0 >> 3 + 0, 36) time: 1223693 sent: 1223693 pen: 1 
1223893 rem: 200                                                                                     
[ 1526.737059] lower bound violation: 0                                                                                                                                          
[ 1526.737125] rto: 200 (0 >> 3 + 0, 39) time: 1226737 sent: 1226693 pen: 1 
1229893 rem: 156                                                                                     
[ 1526.737271] lower bound violation: 0                                                                                                                                          
[ 1526.737323] rto: 200 (0 >> 3 + 0, 38) time: 1226737 sent: 1226693 pen: 1 
1226893 rem: 156                                                                                     
[ 1526.737557] lower bound violation: 0                                                                                                                                          
[ 1526.737607] rto: 200 (0 >> 3 + 0, 37) time: 1226737 sent: 1226693 pen: 1 
1226893 rem: 156                                                                                     
[ 1529.979070] lower bound violation: 0                                                                                                                                          
[ 1529.979130] rto: 200 (0 >> 3 + 0, 40) time: 1229979 sent: 1229693 pen: 1 
1232893 rem: 0                                                                                       
[ 1529.979249] lower bound violation: 0                                                                                                                                          
[ 1529.979304] rto: 200 (0 >> 3 + 0, 40) time: 1229979 sent: 1229979 pen: 1 
1230379 rem: 200                                                                                     
[ 1529.979412] lower bound violation: 0                                                                                                                                          
[ 1529.979461] rto: 200 (0 >> 3 + 0, 39) time: 1229979 sent: 1229979 pen: 1 
1230179 rem: 200                                                                                     
[ 1533.211875] lower bound violation: 0                                                                                                                                          
[ 1533.211934] rto: 200 (0 >> 3 + 0, 42) time: 1233211 sent: 1232979 pen: 1 
1236179 rem: 0                                                                                       
[ 1533.212049] lower bound violation: 0                                                                                                                                          
[ 1533.212098] rto: 200 (0 >> 3 + 0, 42) time: 1233211 sent: 1233211 pen: 1 
1233611 rem: 200                                                                                     
[ 1533.212203] lower bound violation: 0                                                                                                                                          
[ 1533.212259] rto: 200 (0 >> 3 + 0, 41) time: 1233212 sent: 1233211 pen: 1 
1233412 rem: 199                                                                                     
[ 1536.287558] lower bound violation: 0                                                                                                                                          
[ 1536.287611] rto: 200 (0 >> 3 + 0, 44) time: 1236287 sent: 1236211 pen: 1 
1239411 rem: 124                                                                                     
[ 1536.287712] lower bound violation: 0                                                                                                                                          
[ 1536.287760] rto: 200 (0 >> 3 + 0, 43) time: 1236287 sent: 1236211 pen: 1 
1236411 rem: 124                                                                                     
[ 1536.291704] lower bound violation: 0                                                                                                                                          
[ 1536.291767] rto: 200 (0 >> 3 + 0, 42) time: 1236291 sent: 1236211 pen: 1 
1236411 rem: 120                                                                                     
[ 1539.530596] lower bound violation: 0                                                                                                                                          
[ 1539.530657] rto: 200 (0 >> 3 + 0, 45) time: 1239530 sent: 1239211 pen: 1 
1242411 rem: 0                                                                                       
[ 1539.530804] lower bound violation: 0                                                                                                                                          
[ 1539.530862] rto: 200 (0 >> 3 + 0, 45) time: 1239530 sent: 1239530 pen: 1 
1239930 rem: 200                                                                                     
[ 1544.020855] lower bound violation: 0                                                                                                                                          
[ 1544.020916] rto: 200 (0 >> 3 + 0, 48) time: 1244020 sent: 1242530 pen: 1 
1245730 rem: 0                                                                                       
[ 1544.021022] lower bound violation: 0                                                                                                                                          
[ 1544.021071] rto: 200 (0 >> 3 + 0, 48) time: 1244021 sent: 1244020 pen: 1 
1244421 rem: 199                                                                                     
[ 1544.021186] lower bound violation: 0                                                                                                                                          
[ 1544.021243] rto: 200 (0 >> 3 + 0, 47) time: 1244021 sent: 1244020 pen: 1 
1244220 rem: 199                                                                                     
[ 1547.214143] lower bound violation: 0                                                                                                                                          
[ 1547.214212] rto: 200 (0 >> 3 + 0, 50) time: 1247214 sent: 1247020 pen: 1 
1250220 rem: 6                                                                                       
[ 1547.214330] lower bound violation: 0                                                                                                                                          
[ 1547.214388] rto: 200 (0 >> 3 + 0, 49) time: 1247214 sent: 1247020 pen: 1 
1247220 rem: 6                                                                                       
[ 1547.215213] lower bound violation: 0                                                                                                                                          
[ 1547.215269] rto: 200 (0 >> 3 + 0, 48) time: 1247215 sent: 1247020 pen: 1 
1247221 rem: 5                                                                                       
[ 1551.820989] lower bound violation: 0                                                                                                                                          
[ 1551.821059] rto: 200 (0 >> 3 + 0, 51) time: 1251821 sent: 1250020 pen: 1 
1253220 rem: 0                                                                                       
[ 1551.821211] lower bound violation: 0                                                                                                                                          
[ 1551.821265] rto: 200 (0 >> 3 + 0, 51) time: 1251821 sent: 1251821 pen: 1 
1252221 rem: 200                                                                                     
[ 1551.824378] lower bound violation: 0                                                                                                                                          
[ 1551.824437] rto: 200 (0 >> 3 + 0, 50) time: 1251824 sent: 1251821 pen: 1 
1252021 rem: 197                                                                                     
[ 1556.833941] lower bound violation: 0                                                                                                                                          
[ 1556.834001] rto: 200 (0 >> 3 + 0, 53) time: 1256833 sent: 1254821 pen: 1 
1258021 rem: 0                                                                                       
[ 1556.834120] lower bound violation: 0                                                                                                                                          
[ 1556.834168] rto: 200 (0 >> 3 + 0, 53) time: 1256834 sent: 1256834 pen: 1 
1257234 rem: 200                                                                                     
[ 1556.834280] lower bound violation: 0                                                                                                                                          
[ 1556.834335] rto: 200 (0 >> 3 + 0, 52) time: 1256834 sent: 1256834 pen: 1 
1257034 rem: 200                                                                                     
[ 1559.862274] lower bound violation: 0                                                                                                                                          
[ 1559.862332] rto: 200 (0 >> 3 + 0, 55) time: 1259862 sent: 1259834 pen: 1 
1263034 rem: 172                                                                                     
[ 1559.862439] lower bound violation: 0                                                                                                                                          
[ 1559.862488] rto: 200 (0 >> 3 + 0, 54) time: 1259862 sent: 1259834 pen: 1 
1260034 rem: 172                                                                                     
[ 1559.862599] lower bound violation: 0                                                                                                                                          
[ 1559.862653] rto: 200 (0 >> 3 + 0, 53) time: 1259862 sent: 1259834 pen: 1 
1260034 rem: 172                                                                                     
[ 1563.299323] lower bound violation: 0                                                                                                                                          
[ 1563.299392] rto: 200 (0 >> 3 + 0, 56) time: 1263299 sent: 1262834 pen: 1 
1266034 rem: 0                                                                                       
[ 1563.299544] lower bound violation: 0                                                                                                                                          
[ 1563.299593] rto: 200 (0 >> 3 + 0, 56) time: 1263299 sent: 1263299 pen: 1 
1263699 rem: 200                                                                                     
[ 1563.299692] lower bound violation: 0                                                                                                                                          
[ 1563.299740] rto: 200 (0 >> 3 + 0, 55) time: 1263299 sent: 1263299 pen: 1 
1263499 rem: 200                                                                                     
[ 1566.413518] lower bound violation: 0                                                                                                                                          
[ 1566.413571] rto: 200 (0 >> 3 + 0, 58) time: 1266413 sent: 1266299 pen: 1 
1269499 rem: 86                                                                                      
[ 1566.413689] lower bound violation: 0                                                                                                                                          
[ 1566.413745] rto: 200 (0 >> 3 + 0, 57) time: 1266413 sent: 1266299 pen: 1 
1266499 rem: 86                                                                                      
[ 1566.413844] lower bound violation: 0                                                                                                                                          
[ 1566.413892] rto: 200 (0 >> 3 + 0, 56) time: 1266413 sent: 1266299 pen: 1 
1266499 rem: 86                                                                                      
[ 1569.443770] lower bound violation: 0                                                                                                                                          
[ 1569.443829] rto: 200 (0 >> 3 + 0, 59) time: 1269443 sent: 1269299 pen: 1 
1272499 rem: 56                                                                                      
[ 1569.444010] lower bound violation: 0                                                                                                                                          
[ 1569.444064] rto: 200 (0 >> 3 + 0, 58) time: 1269444 sent: 1269299 pen: 1 
1269499 rem: 55                                                                                      
[ 1569.451656] lower bound violation: 0                                                                                                                                          
[ 1569.451714] rto: 200 (0 >> 3 + 0, 57) time: 1269451 sent: 1269299 pen: 1 
1269499 rem: 48                                                                                      
[ 1573.751979] lower bound violation: 0                                                                                                                                          
[ 1573.752048] rto: 200 (0 >> 3 + 0, 60) time: 1273752 sent: 1272299 pen: 1 
1275499 rem: 0                                                                                       
[ 1573.752172] lower bound violation: 0                                                                                                                                          
[ 1573.752229] rto: 200 (0 >> 3 + 0, 60) time: 1273752 sent: 1273752 pen: 1 
1274152 rem: 200                                                                                     
[ 1573.752343] lower bound violation: 0                                                                                                                                          
[ 1573.752392] rto: 200 (0 >> 3 + 0, 59) time: 1273752 sent: 1273752 pen: 1 
1273952 rem: 200                                                                                     
[ 1579.041006] lower bound violation: 0                                                                                                                                          
[ 1579.041068] rto: 200 (0 >> 3 + 0, 62) time: 1279041 sent: 1276752 pen: 1 
1279952 rem: 0                                                                                       
[ 1579.041177] lower bound violation: 0                                                                                                                                          
[ 1579.041226] rto: 200 (0 >> 3 + 0, 62) time: 1279041 sent: 1279041 pen: 1 
1279441 rem: 200                                                                                     
[ 1579.041325] lower bound violation: 0                                                                                                                                          
[ 1579.041373] rto: 200 (0 >> 3 + 0, 61) time: 1279041 sent: 1279041 pen: 1 
1279241 rem: 200                                                                                     
[ 1584.072083] lower bound violation: 0                                                                                                                                          
[ 1584.072149] rto: 200 (0 >> 3 + 0, 64) time: 1284072 sent: 1282041 pen: 1 
1285241 rem: 0                                                                                       
[ 1587.094402] lower bound violation: 0                                                                                                                                          
[ 1587.094461] rto: 200 (0 >> 3 + 0, 67) time: 1287094 sent: 1286872 pen: 1 
1290072 rem: 0                                                                                       
[ 1587.095380] lower bound violation: 0                                                                                                                                          
[ 1587.095442] rto: 200 (0 >> 3 + 0, 67) time: 1287095 sent: 1287094 pen: 1 
1287494 rem: 199                                                                                     
[ 1590.118759] lower bound violation: 0                                                                                                                                          
[ 1590.118818] rto: 200 (0 >> 3 + 0, 70) time: 1290118 sent: 1290094 pen: 1 
1293294 rem: 176                                                                                     
[ 1590.118931] lower bound violation: 0                                                                                                                                          
[ 1590.118979] rto: 200 (0 >> 3 + 0, 69) time: 1290118 sent: 1290094 pen: 1 
1290294 rem: 176                                                                                     
[ 1590.119085] lower bound violation: 0                                                                                                                                          
[ 1590.119142] rto: 200 (0 >> 3 + 0, 68) time: 1290119 sent: 1290094 pen: 1 
1290295 rem: 175                                                                                     
[ 1593.342497] lower bound violation: 0                                                                                                                                          
[ 1593.342556] rto: 200 (0 >> 3 + 0, 71) time: 1293342 sent: 1293094 pen: 1 
1296294 rem: 0                                                                                       
[ 1593.342675] lower bound violation: 0                                                                                                                                          
[ 1593.342723] rto: 200 (0 >> 3 + 0, 71) time: 1293342 sent: 1293342 pen: 1 
1293742 rem: 200                                                                                     
[ 1593.342822] lower bound violation: 0                                                                                                                                          
[ 1593.342870] rto: 200 (0 >> 3 + 0, 70) time: 1293342 sent: 1293342 pen: 1 
1293542 rem: 200                                                                                     
[ 1597.517273] lower bound violation: 0                                                                                                                                          
[ 1597.517326] rto: 200 (0 >> 3 + 0, 73) time: 1297517 sent: 1296342 pen: 1 
1299542 rem: 0                                                                                       
[ 1597.517433] lower bound violation: 0                                                                                                                                          
[ 1597.517481] rto: 200 (0 >> 3 + 0, 73) time: 1297517 sent: 1297517 pen: 1 
1297917 rem: 200                                                                                     
[ 1597.517579] lower bound violation: 0                                                                                                                                          
[ 1597.517627] rto: 200 (0 >> 3 + 0, 72) time: 1297517 sent: 1297517 pen: 1 
1297717 rem: 200                                                                                     
[ 1600.931564] lower bound violation: 0                                                                                                                                          
[ 1600.931625] rto: 200 (0 >> 3 + 0, 75) time: 1300931 sent: 1300517 pen: 1 
1303717 rem: 0                                                                                       
[ 1600.931743] lower bound violation: 0                                                                                                                                          
[ 1600.931792] rto: 200 (0 >> 3 + 0, 75) time: 1300931 sent: 1300931 pen: 1 
1301331 rem: 200                                                                                     
[ 1600.931903] lower bound violation: 0                                                                                                                                          
[ 1600.931954] rto: 200 (0 >> 3 + 0, 74) time: 1300931 sent: 1300931 pen: 1 
1301131 rem: 200                                                                                     
[ 1603.939116] lower bound violation: 0                                                                                                                                          
[ 1603.939176] rto: 200 (0 >> 3 + 0, 77) time: 1303939 sent: 1303932 pen: 1 
1307132 rem: 193                                                                                     
[ 1603.939289] lower bound violation: 0                                                                                                                                          
[ 1603.939337] rto: 200 (0 >> 3 + 0, 76) time: 1303939 sent: 1303932 pen: 1 
1304132 rem: 193                                                                                     
[ 1603.939436] lower bound violation: 0                                                                                                                                          
[ 1603.939484] rto: 200 (0 >> 3 + 0, 75) time: 1303939 sent: 1303932 pen: 1 
1304132 rem: 193                                                                                     
[ 1607.414745] lower bound violation: 0                                                                                                                                          
[ 1607.414808] rto: 200 (0 >> 3 + 0, 78) time: 1307414 sent: 1306932 pen: 1 
1310132 rem: 0                                                                                       
[ 1607.414956] lower bound violation: 0                                                                                                                                          
[ 1607.415015] rto: 200 (0 >> 3 + 0, 78) time: 1307414 sent: 1307414 pen: 1 
1307814 rem: 200                                                                                     
[ 1610.428738] lower bound violation: 0                                                                                                                                          
[ 1610.428797] rto: 200 (0 >> 3 + 0, 81) time: 1310428 sent: 1310414 pen: 1 
1313614 rem: 186                                                                                     
[ 1610.428909] lower bound violation: 0                                                                                                                                          
[ 1610.428957] rto: 200 (0 >> 3 + 0, 80) time: 1310428 sent: 1310414 pen: 1 
1310614 rem: 186                                                                                     
[ 1610.429061] lower bound violation: 0                                                                                                                                          
[ 1610.429118] rto: 200 (0 >> 3 + 0, 79) time: 1310428 sent: 1310414 pen: 1 
1310614 rem: 186                                                                                     
[ 1613.744633] lower bound violation: 0                                                                                                                                          
[ 1613.744696] rto: 200 (0 >> 3 + 0, 82) time: 1313744 sent: 1313415 pen: 1 
1316615 rem: 0                                                                                       
[ 1613.745417] lower bound violation: 0                                                                                                                                          
[ 1613.745480] rto: 200 (0 >> 3 + 0, 82) time: 1313745 sent: 1313744 pen: 1 
1314144 rem: 199                                                                                     
[ 1617.868468] lower bound violation: 0                                                                                                                                          
[ 1617.868531] rto: 200 (0 >> 3 + 0, 85) time: 1317868 sent: 1316744 pen: 1 
1319944 rem: 0                                                                                       
[ 1617.868657] lower bound violation: 0                                                                                                                                          
[ 1617.868716] rto: 200 (0 >> 3 + 0, 85) time: 1317868 sent: 1317868 pen: 1 
1318268 rem: 200                                                                                     
[ 1617.868831] rto: 120000 (18111 >> 3 + 2633, 7) time: 1317868 sent: 1315423 
pen: 1 1435423 rem: 117555                                                                         
[ 1621.001005] lower bound violation: 0                                                                                                                                          
[ 1621.001064] rto: 200 (0 >> 3 + 0, 88) time: 1321000 sent: 1320868 pen: 1 
1324068 rem: 68                                                                                      
[ 1621.001176] lower bound violation: 0                                                                                                                                          
[ 1621.001225] rto: 200 (0 >> 3 + 0, 87) time: 1321000 sent: 1320868 pen: 1 
1321068 rem: 68                                                                                      
[ 1621.002106] rto: 120000 (17704 >> 3 + 4426, 8) time: 1321002 sent: 1318638 
pen: 1 1438638 rem: 117636                                                                         
[ 1624.776425] lower bound violation: 0                                                                                                                                          
[ 1624.776484] rto: 200 (0 >> 3 + 0, 90) time: 1324776 sent: 1323868 pen: 1 
1327068 rem: 0                                                                                       
[ 1624.776602] lower bound violation: 0                                                                                                                                          
[ 1624.776651] rto: 200 (0 >> 3 + 0, 90) time: 1324776 sent: 1324776 pen: 1 
1325176 rem: 200                                                                                     
[ 1624.776766] lower bound violation: 0                                                                                                                                          
[ 1624.776815] rto: 200 (0 >> 3 + 0, 89) time: 1324776 sent: 1324776 pen: 1 
1324976 rem: 200                                                                                     
[ 1628.635107] lower bound violation: 0                                                                                                                                          
[ 1628.635166] rto: 200 (0 >> 3 + 0, 92) time: 1328635 sent: 1327776 pen: 1 
1330976 rem: 0                                                                                       
[ 1628.635292] lower bound violation: 0                                                                                                                                          
[ 1628.635340] rto: 200 (0 >> 3 + 0, 92) time: 1328635 sent: 1328635 pen: 1 
1329035 rem: 200                                                                                     
[ 1628.636141] lower bound violation: 0                                                                                                                                          
[ 1628.636189] rto: 200 (0 >> 3 + 0, 91) time: 1328636 sent: 1328635 pen: 1 
1328836 rem: 199                                                                                     
[ 1632.229674] lower bound violation: 0                                                                                                                                          
[ 1632.229736] rto: 200 (0 >> 3 + 0, 94) time: 1332229 sent: 1331635 pen: 1 
1334835 rem: 0                                                                                       
[ 1632.231588] lower bound violation: 0                                                                                                                                          
[ 1632.231645] rto: 200 (0 >> 3 + 0, 94) time: 1332231 sent: 1332229 pen: 1 
1332629 rem: 198                                                                                     
[ 1636.335644] lower bound violation: 0                                                                                                                                          
[ 1636.335704] rto: 200 (0 >> 3 + 0, 97) time: 1336335 sent: 1335229 pen: 1 
1338429 rem: 0                                                                                       
[ 1636.335821] lower bound violation: 0                                                                                                                                          
[ 1636.335870] rto: 200 (0 >> 3 + 0, 97) time: 1336335 sent: 1336335 pen: 1 
1336735 rem: 200                                                                                     
[ 1636.335968] lower bound violation: 0                                                                                                                                          
[ 1636.336015] rto: 200 (0 >> 3 + 0, 96) time: 1336335 sent: 1336335 pen: 1 
1336535 rem: 200                                                                                     
[ 1639.557760] lower bound violation: 0                                                                                                                                          
[ 1639.557819] rto: 200 (0 >> 3 + 0, 99) time: 1339557 sent: 1339336 pen: 1 
1342536 rem: 0                                                                                       
[ 1639.557937] lower bound violation: 0                                                                                                                                          
[ 1639.557985] rto: 200 (0 >> 3 + 0, 99) time: 1339557 sent: 1339557 pen: 1 
1339957 rem: 200                                                                                     
[ 1639.558575] lower bound violation: 0                                                                                                                                          
[ 1639.558631] rto: 200 (0 >> 3 + 0, 98) time: 1339558 sent: 1339557 pen: 1 
1339758 rem: 199                                                                                     
[ 1642.786990] lower bound violation: 0                                                                                                                                          
[ 1642.787060] rto: 200 (0 >> 3 + 0, 101) time: 1342787 sent: 1342557 pen: 1 
1345757 rem: 0                                                                                      
[ 1642.787238] lower bound violation: 0                                                                                                                                          
[ 1642.787296] rto: 200 (0 >> 3 + 0, 101) time: 1342787 sent: 1342787 pen: 1 
1343187 rem: 200                                                                                    
[ 1642.787395] lower bound violation: 0                                                                                                                                          
[ 1642.787444] rto: 200 (0 >> 3 + 0, 100) time: 1342787 sent: 1342787 pen: 1 
1342987 rem: 200                                                                                    
[ 1647.154582] lower bound violation: 0                                                                                                                                          
[ 1647.154634] rto: 200 (0 >> 3 + 0, 103) time: 1347154 sent: 1345787 pen: 1 
1348987 rem: 0                                                                                      
[ 1647.154744] lower bound violation: 0                                                                                                                                          
[ 1647.154792] rto: 200 (0 >> 3 + 0, 103) time: 1347154 sent: 1347154 pen: 1 
1347554 rem: 200                                                                                    
[ 1647.154904] lower bound violation: 0                                                                                                                                          
[ 1647.154952] rto: 200 (0 >> 3 + 0, 102) time: 1347154 sent: 1347154 pen: 1 
1347354 rem: 200                                                                                    
[ 1650.574345] lower bound violation: 0                                                                                                                                          
[ 1650.574406] rto: 200 (0 >> 3 + 0, 105) time: 1350574 sent: 1350155 pen: 1 
1353355 rem: 0                                                                                      
[ 1650.574532] lower bound violation: 0                                                                                                                                          
[ 1650.574591] rto: 200 (0 >> 3 + 0, 105) time: 1350574 sent: 1350574 pen: 1 
1350974 rem: 200                                                                                    
[ 1650.574691] lower bound violation: 0                                                                                                                                          
[ 1650.574739] rto: 200 (0 >> 3 + 0, 104) time: 1350574 sent: 1350574 pen: 1 
1350774 rem: 200                                                                                    
[ 1653.629874] lower bound violation: 0                                                                                                                                          
[ 1653.629937] rto: 200 (0 >> 3 + 0, 107) time: 1353629 sent: 1353574 pen: 1 
1356774 rem: 145                                                                                    
[ 1653.630037] lower bound violation: 0                                                                                                                                          
[ 1653.630086] rto: 200 (0 >> 3 + 0, 106) time: 1353629 sent: 1353574 pen: 1 
1353774 rem: 145                                                                                    
[ 1653.630185] lower bound violation: 0                                                                                                                                          
[ 1653.630233] rto: 200 (0 >> 3 + 0, 105) time: 1353629 sent: 1353574 pen: 1 
1353774 rem: 145                                                                                    
[ 1656.859174] lower bound violation: 0                                                                                                                                          
[ 1656.859236] rto: 200 (0 >> 3 + 0, 108) time: 1356859 sent: 1356574 pen: 1 
1359774 rem: 0                                                                                      
[ 1656.860594] lower bound violation: 0                                                                                                                                          
[ 1656.860650] rto: 200 (0 >> 3 + 0, 108) time: 1356860 sent: 1356859 pen: 1 
1357259 rem: 199                                                                                    
[ 1656.860770] lower bound violation: 0                                                                                                                                          
[ 1656.860818] rto: 200 (0 >> 3 + 0, 107) time: 1356860 sent: 1356859 pen: 1 
1357059 rem: 199                                                                                    
[ 1661.395294] lower bound violation: 0                                                                                                                                          
[ 1661.395347] rto: 200 (0 >> 3 + 0, 110) time: 1361395 sent: 1359859 pen: 1 
1363059 rem: 0                                                                                      
[ 1661.395716] lower bound violation: 0                                                                                                                                          
[ 1661.395772] rto: 200 (0 >> 3 + 0, 110) time: 1361395 sent: 1361395 pen: 1 
1361795 rem: 200                                                                                    
[ 1700.995078] rto: 120000 (2636 >> 3 + 542, 8) time: 1400995 sent: 1397985 
pen: 1 1517985 rem: 116990                                                                           
[ 1730.706641] lower bound violation: 0                                                                                                                                          
[ 1730.706700] rto: 200 (0 >> 3 + 0, 7) time: 1430706 sent: 1429991 pen: 1 
1549991 rem: 0                                                                                        
[ 1733.727118] lower bound violation: 0                                                                                                                                          
[ 1733.727186] rto: 200 (0 >> 3 + 0, 10) time: 1433727 sent: 1433506 pen: 1 
1436706 rem: 0                                                                                       
[ 1736.737622] lower bound violation: 0                                                                                                                                          
[ 1736.737674] rto: 200 (0 >> 3 + 0, 13) time: 1436737 sent: 1436527 pen: 1 
1439727 rem: 0                                                                                       
[ 1739.769166] lower bound violation: 0                                                                                                                                          
[ 1739.769219] rto: 200 (0 >> 3 + 0, 16) time: 1439769 sent: 1439537 pen: 1 
1442737 rem: 0                                                                                       
[ 1739.818141] lower bound violation: 0                                                                                                                                          
[ 1739.818197] rto: 200 (0 >> 3 + 0, 16) time: 1439818 sent: 1439769 pen: 1 
1440169 rem: 151                                                                                     
[ 1742.779541] lower bound violation: 0                                                                                                                                          
[ 1742.779610] rto: 200 (0 >> 3 + 0, 19) time: 1442779 sent: 1442769 pen: 1 
1445969 rem: 190                                                                                     
[ 1742.828450] lower bound violation: 0                                                                                                                                          
[ 1742.828509] rto: 200 (0 >> 3 + 0, 18) time: 1442828 sent: 1442769 pen: 1 
1442969 rem: 141                                                                                     
[ 1745.838989] lower bound violation: 0                                                                                                                                          
[ 1745.839059] rto: 200 (0 >> 3 + 0, 21) time: 1445839 sent: 1445769 pen: 1 
1448969 rem: 130                                                                                     
[ 1748.849390] lower bound violation: 0                                                                                                                                          
[ 1748.849450] rto: 200 (0 >> 3 + 0, 24) time: 1448849 sent: 1448769 pen: 1 
1451969 rem: 120                                                                                     
[ 1751.851312] lower bound violation: 0                                                                                                                                          
[ 1751.851371] rto: 200 (0 >> 3 + 0, 27) time: 1451851 sent: 1451769 pen: 1 
1454969 rem: 118                                                                                     
[ 1755.020232] lower bound violation: 0                                                                                                                                          
[ 1755.020294] rto: 200 (0 >> 3 + 0, 30) time: 1455020 sent: 1454769 pen: 1 
1457969 rem: 0                                                                                       
[ 1758.032994] lower bound violation: 0                                                                                                                                          
[ 1758.033065] rto: 200 (0 >> 3 + 0, 33) time: 1458032 sent: 1457820 pen: 1 
1461020 rem: 0                                                                                       
[ 1761.044708] lower bound violation: 0                                                                                                                                          
[ 1761.044766] rto: 200 (0 >> 3 + 0, 36) time: 1461044 sent: 1460833 pen: 1 
1464033 rem: 0                                                                                       
[ 1764.057713] lower bound violation: 0                                                                                                                                          
[ 1764.057773] rto: 200 (0 >> 3 + 0, 39) time: 1464057 sent: 1463844 pen: 1 
1467044 rem: 0                                                                                       
[ 1767.081929] lower bound violation: 0                                                                                                                                          
[ 1767.082002] rto: 200 (0 >> 3 + 0, 42) time: 1467081 sent: 1466857 pen: 1 
1470057 rem: 0                                                                                       
[ 1770.093869] lower bound violation: 0                                                                                                                                          
[ 1770.093928] rto: 200 (0 >> 3 + 0, 45) time: 1470093 sent: 1469882 pen: 1 
1473082 rem: 0                                                                                       
[ 1773.152744] lower bound violation: 0                                                                                                                                          
[ 1773.152796] rto: 200 (0 >> 3 + 0, 48) time: 1473152 sent: 1472893 pen: 1 
1476093 rem: 0                                                                                       
[ 1818.986470] rto: 120000 (2636 >> 3 + 542, 8) time: 1518986 sent: 1517985 
pen: 1 1637985 rem: 118999                                                                           
[ 1939.433063] rto: 120000 (2636 >> 3 + 542, 8) time: 1639432 sent: 1637985 
pen: 1 1757985 rem: 118553                                                                           
[ 2127.032954] lower bound violation: 0                                                                                                                                          
[ 2127.033019] rto: 200 (0 >> 3 + 0, 5) time: 1827033 sent: 1824734 pen: 1 
1944734 rem: 0                                                                                        
[ 2130.198949] lower bound violation: 0                                                                                                                                          
[ 2130.199008] rto: 200 (0 >> 3 + 0, 8) time: 1830198 sent: 1829833 pen: 1 
1833033 rem: 0                                                                                        
[ 2130.199134] lower bound violation: 0                                                                                                                                          
[ 2130.199191] rto: 200 (0 >> 3 + 0, 8) time: 1830199 sent: 1830199 pen: 1 
1830599 rem: 200                                                                                      
[ 2130.199289] lower bound violation: 0                                                                                                                                          
[ 2130.199336] rto: 200 (0 >> 3 + 0, 7) time: 1830199 sent: 1830199 pen: 1 
1830399 rem: 200                                                                                      
[ 2133.313262] lower bound violation: 0                                                                                                                                          
[ 2133.313321] rto: 200 (0 >> 3 + 0, 10) time: 1833313 sent: 1833199 pen: 1 
1836399 rem: 86                                                                                      
[ 2133.313430] lower bound violation: 0                                                                                                                                          
[ 2133.313483] rto: 200 (0 >> 3 + 0, 9) time: 1833313 sent: 1833199 pen: 1 
1833399 rem: 86                                                                                       
[ 2136.355135] lower bound violation: 0                                                                                                                                          
[ 2136.355194] rto: 200 (0 >> 3 + 0, 12) time: 1836355 sent: 1836199 pen: 1 
1839399 rem: 44                                                                                      
[ 2136.355302] lower bound violation: 0                                                                                                                                          
[ 2136.355355] rto: 200 (0 >> 3 + 0, 11) time: 1836355 sent: 1836199 pen: 1 
1836399 rem: 44                                                                                      
[ 2136.355462] lower bound violation: 0                                                                                                                                          
[ 2136.355510] rto: 200 (0 >> 3 + 0, 10) time: 1836355 sent: 1836199 pen: 1 
1836399 rem: 44                                                                                      
[ 2139.336730] lower bound violation: 0                                                                                                                                          
[ 2139.336790] rto: 200 (0 >> 3 + 0, 13) time: 1839336 sent: 1839199 pen: 1 
1842399 rem: 63                                                                                      
[ 2139.336911] lower bound violation: 0                                                                                                                                          
[ 2139.336960] rto: 200 (0 >> 3 + 0, 12) time: 1839336 sent: 1839199 pen: 1 
1839399 rem: 63                                                                                      
[ 2142.603552] lower bound violation: 0                                                                                                                                          
[ 2142.603612] rto: 200 (0 >> 3 + 0, 15) time: 1842603 sent: 1842200 pen: 1 
1845400 rem: 0                                                                                       
[ 2142.603729] lower bound violation: 0                                                                                                                                          
[ 2142.603777] rto: 200 (0 >> 3 + 0, 15) time: 1842603 sent: 1842603 pen: 1 
1843003 rem: 200                                                                                     
[ 2145.821472] lower bound violation: 0                                                                                                                                          
[ 2145.821533] rto: 200 (0 >> 3 + 0, 18) time: 1845821 sent: 1845603 pen: 1 
1848803 rem: 0                                                                                       
[ 2145.821638] lower bound violation: 0                                                                                                                                          
[ 2145.821687] rto: 200 (0 >> 3 + 0, 18) time: 1845821 sent: 1845821 pen: 1 
1846221 rem: 200                                                                                     
[ 2149.113311] lower bound violation: 0                                                                                                                                          
[ 2149.113371] rto: 200 (0 >> 3 + 0, 21) time: 1849113 sent: 1848822 pen: 1 
1852022 rem: 0                                                                                       
[ 2149.124655] lower bound violation: 0                                                                                                                                          
[ 2149.124717] rto: 200 (0 >> 3 + 0, 21) time: 1849124 sent: 1849113 pen: 1 
1849513 rem: 189                                                                                     
[ 2152.214537] lower bound violation: 0                                                                                                                                          
[ 2152.214596] rto: 200 (0 >> 3 + 0, 24) time: 1852214 sent: 1852113 pen: 1 
1855313 rem: 99                                                                                      
[ 2152.214836] lower bound violation: 0                                                                                                                                          
[ 2152.214892] rto: 200 (0 >> 3 + 0, 23) time: 1852214 sent: 1852113 pen: 1 
1852313 rem: 99                                                                                      
[ 2152.216836] lower bound violation: 0                                                                                                                                          
[ 2152.216892] rto: 200 (0 >> 3 + 0, 22) time: 1852216 sent: 1852113 pen: 1 
1852313 rem: 97                                                                                      
[ 2155.212630] lower bound violation: 0                                                                                                                                          
[ 2155.212683] rto: 200 (0 >> 3 + 0, 25) time: 1855212 sent: 1855113 pen: 1 
1858313 rem: 101                                                                                     
[ 2155.271403] lower bound violation: 0                                                                                                                                          
[ 2155.271462] rto: 200 (0 >> 3 + 0, 24) time: 1855271 sent: 1855113 pen: 1 
1855313 rem: 42                                                                                      
[ 2155.271570] lower bound violation: 0                                                                                                                                          
[ 2155.271624] rto: 200 (0 >> 3 + 0, 23) time: 1855271 sent: 1855113 pen: 1 
1855313 rem: 42                                                                                      
[ 2158.247617] lower bound violation: 0                                                                                                                                          
[ 2158.247676] rto: 200 (0 >> 3 + 0, 26) time: 1858247 sent: 1858113 pen: 1 
1861313 rem: 66                                                                                      
[ 2158.308891] lower bound violation: 0                                                                                                                                          
[ 2158.308949] rto: 200 (0 >> 3 + 0, 25) time: 1858308 sent: 1858113 pen: 1 
1858313 rem: 5                                                                                       
[ 2161.267856] lower bound violation: 0                                                                                                                                          
[ 2161.267918] rto: 200 (0 >> 3 + 0, 28) time: 1861267 sent: 1861114 pen: 1 
1864314 rem: 47                                                                                      
[ 2161.268020] lower bound violation: 0                                                                                                                                          
[ 2161.268068] rto: 200 (0 >> 3 + 0, 27) time: 1861268 sent: 1861114 pen: 1 
1861315 rem: 46                                                                                      
[ 2161.268283] lower bound violation: 0                                                                                                                                          
[ 2161.268339] rto: 200 (0 >> 3 + 0, 26) time: 1861268 sent: 1861114 pen: 1 
1861314 rem: 46                                                                                      
[ 2164.483740] lower bound violation: 0                                                                                                                                          
[ 2164.483799] rto: 200 (0 >> 3 + 0, 29) time: 1864483 sent: 1864114 pen: 1 
1867314 rem: 0                                                                                       
[ 2164.485758] lower bound violation: 0                                                                                                                                          
[ 2164.485809] rto: 200 (0 >> 3 + 0, 29) time: 1864485 sent: 1864483 pen: 1 
1864883 rem: 198                                                                                     
[ 2460.739324] rto: 7040 (757 >> 3 + 346, 4) time: 2160739 sent: 2160696 pen: 
1 2174776 rem: 6997                                                                                
[ 2477.769916] rto: 120000 (17147 >> 3 + 1705, 6) time: 2177769 sent: 2174642 
pen: 1 2294642 rem: 116873                                                                         
[ 2484.364919] rto: 69440 (3542 >> 3 + 643, 6) time: 2184364 sent: 2182505 
pen: 1 2302505 rem: 67581                                                                             
[ 2555.105348] rto: 69440 (3542 >> 3 + 643, 6) time: 2255105 sent: 2251946 
pen: 1 2371946 rem: 66281                                                                             
[ 2597.920272] rto: 120000 (17147 >> 3 + 1705, 6) time: 2297920 sent: 2294643 
pen: 1 2414643 rem: 116723                                                                         
[ 2624.616823] rto: 69440 (3542 >> 3 + 643, 6) time: 2324616 sent: 2321386 
pen: 1 2441386 rem: 66210                                                                             
[ 2693.911647] rto: 69440 (3542 >> 3 + 643, 6) time: 2393911 sent: 2390826 
pen: 1 2510826 rem: 66355                                                                             
[ 2763.385982] rto: 69440 (3542 >> 3 + 643, 6) time: 2463385 sent: 2460266 
pen: 1 2580266 rem: 66321                                                                             
[ 2779.512699] rto: 1256 (1556 >> 3 + 434, 1) time: 2479512 sent: 2478219 pen: 
1 2480731 rem: 0                                                                                  
[ 2832.786161] rto: 69440 (3542 >> 3 + 643, 6) time: 2532786 sent: 2529707 
pen: 1 2649707 rem: 66361                                                                             
[ 2851.953268] rto: 120000 (9704 >> 3 + 2426, 7) time: 2551953 sent: 2548934 
pen: 1 2668934 rem: 116981                                                                          
[ 2902.338631] rto: 69440 (3542 >> 3 + 643, 6) time: 2602338 sent: 2599147 
pen: 1 2719147 rem: 66249                                                                             
[ 2957.718611] rto: 120000 (17147 >> 3 + 1705, 8) time: 2657718 sent: 2654643 
pen: 1 2774643 rem: 116925                                                                         
[ 2971.736295] rto: 69440 (3542 >> 3 + 643, 6) time: 2671736 sent: 2668587 
pen: 1 2788587 rem: 66291                                                                             
[ 2972.118479] rto: 120000 (9704 >> 3 + 2426, 7) time: 2672118 sent: 2668934 
pen: 1 2788934 rem: 116816                                                                          
[ 3041.036185] rto: 69440 (3542 >> 3 + 643, 6) time: 2741036 sent: 2738027 
pen: 1 2858027 rem: 66431                                                                             
[ 3091.942676] rto: 120000 (9704 >> 3 + 2426, 7) time: 2791942 sent: 2788934 
pen: 1 2908934 rem: 116992                                                                          
[ 3110.560285] rto: 69440 (3542 >> 3 + 643, 6) time: 2810560 sent: 2807467 
pen: 1 2927467 rem: 66347                                                                             
[ 3180.044502] rto: 69440 (3542 >> 3 + 643, 6) time: 2880044 sent: 2876907 
pen: 1 2996907 rem: 66303                                                                             
[ 3211.952300] rto: 120000 (9704 >> 3 + 2426, 7) time: 2911952 sent: 2908934 
pen: 1 3028934 rem: 116982                                                                          
[ 3288.275909] rto: 120000 (9674 >> 3 + 2484, 9) time: 2988275 sent: 2987173 
pen: 1 3107173 rem: 118898                                                                          
[ 3330.221683] rto: 120000 (200 >> 3 + 200, 13) time: 3030221 sent: 3027658 
pen: 1 3147658 rem: 117437                                                                           
[ 3383.376964] rto: 13296 (1388 >> 3 + 658, 4) time: 3083376 sent: 3082998 
pen: 1 3109590 rem: 12918                                                                             
[ 3408.805976] rto: 120000 (9674 >> 3 + 2484, 9) time: 3108805 sent: 3107174 
pen: 1 3227174 rem: 118369                                                                          
[ 3447.968663] rto: 120000 (200 >> 3 + 200, 13) time: 3147968 sent: 3147658 
pen: 1 3267658 rem: 119690                                                                           
[ 3798.180697] rto: 1482 (1976 >> 3 + 494, 1) time: 3498180 sent: 3497035 pen: 
1 3499999 rem: 337
[ 3798.180827] rto: 741 (1976 >> 3 + 494, 0) time: 3498180 sent: 3497035 pen: 
1 3498517 rem: 0
[ 3801.277029] rto: 1482 (1976 >> 3 + 494, 1) time: 3501276 sent: 3499662 pen: 
1 3502626 rem: 0
[ 3801.277184] rto: 1482 (1976 >> 3 + 494, 1) time: 3501277 sent: 3501277 pen: 
1 3504241 rem: 1482
[ 3804.486861] rto: 1482 (1976 >> 3 + 494, 1) time: 3504486 sent: 3502759 pen: 
1 3505723 rem: 0
[ 3804.487007] rto: 1482 (1976 >> 3 + 494, 1) time: 3504486 sent: 3504486 pen: 
1 3507450 rem: 1482
[ 3812.053012] rto: 2964 (1976 >> 3 + 494, 2) time: 3512052 sent: 3508933 pen: 
1 3514861 rem: 0
[ 3815.238764] rto: 2964 (1976 >> 3 + 494, 2) time: 3515238 sent: 3512053 pen: 
1 3517981 rem: 0
[ 3818.394748] rto: 2964 (1976 >> 3 + 494, 2) time: 3518394 sent: 3515238 pen: 
1 3521166 rem: 0
[ 3821.481936] rto: 2964 (1976 >> 3 + 494, 2) time: 3521481 sent: 3518394 pen: 
1 3524322 rem: 0
[ 3824.873120] rto: 2964 (1976 >> 3 + 494, 2) time: 3524873 sent: 3521482 pen: 
1 3527410 rem: 0
[ 3827.898656] rto: 2964 (1976 >> 3 + 494, 2) time: 3527898 sent: 3524873 pen: 
1 3530801 rem: 0
[ 3830.943112] rto: 2964 (1976 >> 3 + 494, 2) time: 3530943 sent: 3527898 pen: 
1 3533826 rem: 0
[ 3833.974064] rto: 2964 (1976 >> 3 + 494, 2) time: 3533974 sent: 3530943 pen: 
1 3536871 rem: 0
[ 3837.112487] rto: 2964 (1976 >> 3 + 494, 2) time: 3537112 sent: 3533974 pen: 
1 3539902 rem: 0
[ 3840.130296] rto: 2964 (1976 >> 3 + 494, 2) time: 3540130 sent: 3537112 pen: 
1 3543040 rem: 0
[ 3843.191881] rto: 2964 (1976 >> 3 + 494, 2) time: 3543191 sent: 3540130 pen: 
1 3546058 rem: 0
[ 3846.633862] rto: 2964 (1976 >> 3 + 494, 2) time: 3546633 sent: 3543191 pen: 
1 3549119 rem: 0
[ 3849.682215] rto: 2964 (1976 >> 3 + 494, 2) time: 3549682 sent: 3546633 pen: 
1 3552561 rem: 0
[ 3852.728190] rto: 2964 (1976 >> 3 + 494, 2) time: 3552728 sent: 3549682 pen: 
1 3555610 rem: 0
[ 3869.778290] rto: 79136 (14257 >> 3 + 691, 5) time: 3569778 sent: 3564894 
pen: 1 3684894 rem: 74252
[ 3942.001467] rto: 47424 (1976 >> 3 + 494, 6) time: 3642001 sent: 3641648 
pen: 1 3736496 rem: 47071
[ 3948.754452] rto: 79136 (14257 >> 3 + 691, 5) time: 3648754 sent: 3644030 
pen: 1 3764030 rem: 74412
[ 3972.841345] rto: 47168 (1911 >> 3 + 499, 6) time: 3672841 sent: 3672158 
pen: 1 3766494 rem: 46485
[ 3992.364664] rto: 47424 (1976 >> 3 + 494, 6) time: 3692364 sent: 3689072 
pen: 1 3783920 rem: 44132
[ 4019.342183] rto: 47168 (1911 >> 3 + 499, 6) time: 3719342 sent: 3719326 
pen: 1 3813662 rem: 47152
[ 4028.049905] rto: 79136 (14257 >> 3 + 691, 5) time: 3728049 sent: 3723166 
pen: 1 3843166 rem: 74253
[ 4039.530444] rto: 47424 (1976 >> 3 + 494, 6) time: 3739530 sent: 3736496 
pen: 1 3831344 rem: 44390
[ 4067.954752] rto: 47168 (1911 >> 3 + 499, 6) time: 3767954 sent: 3766494 
pen: 1 3860830 rem: 45708
[ 4087.534683] rto: 47424 (1976 >> 3 + 494, 6) time: 3787534 sent: 3783920 
pen: 1 3878768 rem: 43810
[ 4116.817143] rto: 47168 (1911 >> 3 + 499, 6) time: 3816817 sent: 3813662 
pen: 1 3907998 rem: 44013
[ 4134.515420] rto: 47424 (1976 >> 3 + 494, 6) time: 3834515 sent: 3831344 
pen: 1 3926192 rem: 44253
[ 4146.622061] rto: 40592 (3300 >> 3 + 2125, 4) time: 3846622 sent: 3846199 
pen: 1 3927383 rem: 40169
[ 4182.217172] rto: 47424 (1976 >> 3 + 494, 6) time: 3882217 sent: 3878768 
pen: 1 3973616 rem: 43975
[ 4226.387945] rto: 120000 (14257 >> 3 + 691, 6) time: 3926387 sent: 3922303 
pen: 1 4042303 rem: 115916
[ 4228.876327] rto: 85152 (11055 >> 3 + 1280, 5) time: 3928876 sent: 3925792 
pen: 1 4045792 rem: 82068
[ 4229.248393] rto: 47424 (1976 >> 3 + 494, 6) time: 3929248 sent: 3926192 
pen: 1 4021040 rem: 44368
[ 4264.022196] rto: 103072 (11062 >> 3 + 1839, 5) time: 3964022 sent: 3963411 
pen: 1 4083411 rem: 102461
[ 4271.074364] rto: 81184 (3300 >> 3 + 2125, 5) time: 3971074 sent: 3967975 
pen: 1 4087975 rem: 78085
[ 4276.683784] rto: 47424 (1976 >> 3 + 494, 6) time: 3976683 sent: 3973616 
pen: 1 4068464 rem: 44357
